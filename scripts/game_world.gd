class_name GameWorld extends Node2D

signal open_game_world(game_world: GameWorld)

@onready var tilemap: TileMapLayer = $SubViewportContainer/GameViewport/TileMapLayer
@onready var tileset: TileSet = tilemap.tile_set
@onready var character: Character = $SubViewportContainer/GameViewport/TileMapLayer/Character
@onready var exit_button: TextureButton = $ExitButton
@onready var camera: Camera2D = $SubViewportContainer/GameViewport/Camera2D

const grass_tiles := [Vector2i(0, 0), Vector2i(1, 0)]
const enemy_tiles := [Vector2i(0, 0), Vector2i(0, 1), Vector2i(0, 2), Vector2i(0, 3),
  Vector2i(0, 4)]
const portal_tiles := [Vector2i(0, 0), Vector2i(1, 0), Vector2i(2, 0), Vector2i(3, 0),
  Vector2i(4, 0), Vector2i(5, 0), Vector2i(6, 0)]
const orc_animation: Array[Vector2i] = [Vector2i(1, 0), Vector2i(2, 0), Vector2i(3, 0),
  Vector2i(4, 0)]
const snake_animation: Array[Vector2i] = [Vector2i(1, 1), Vector2i(2, 1), Vector2i(3, 1),
  Vector2i(4, 1)]
const spider_animation: Array[Vector2i] = [Vector2i(1, 2), Vector2i(2, 2), Vector2i(3, 2),
  Vector2i(4, 2)]
const skeleton_animation: Array[Vector2i] = [Vector2i(1, 3), Vector2i(2, 3), Vector2i(3, 3),
  Vector2i(4, 3)]
const succubus_animation: Array[Vector2i] = [Vector2i(1, 4), Vector2i(2, 4), Vector2i(3, 4),
  Vector2i(4, 4)]
const enemy_animations: Dictionary = {
  Difficulty.Modest: orc_animation,
  Difficulty.NoteWorthy: snake_animation,
  Difficulty.Commendable: spider_animation,
  Difficulty.Glorious: skeleton_animation,
  Difficulty.Heroic: succubus_animation
}

const grass_source_id := 0
const enemy_source_id := 1
const portal_source_id := 2
const tile_size = Vector2i(64, 64)
const difficulty_to_enemy_index := {
  Difficulty.Modest: 0,
  Difficulty.NoteWorthy: 1,
  Difficulty.Commendable: 2,
  Difficulty.Glorious: 3,
  Difficulty.Heroic: 4,
}

const difficulty_to_portal_index := {
  Difficulty.Heroic: 0,
  Difficulty.Majestic: 1,
  Difficulty.Legendary: 2,
  Difficulty.Imperial: 3,
  Difficulty.Supreme: 4,
  Difficulty.Transcendent: 5,
}

const mouse_btn_bit_values := {
  MOUSE_BUTTON_LEFT: 1,
  MOUSE_BUTTON_RIGHT: 2,
  MOUSE_BUTTON_WHEEL_UP: 4,
  MOUSE_BUTTON_WHEEL_DOWN: 8 
}

const repeatable_check_interval := 5.0 # 24 * 60 * 60.0

const position_key := "position"

const GameWorldScene := preload("res://scenes/GameWorld.tscn")
const TaskScreenScene := preload("res://scenes/TaskoidScreenBase.tscn")
const ProjectScreenScene := preload("res://scenes/ProjectScreen.tscn")

class DrawConfig extends RefCounted:
  var source_id: int = -1
  var tile_index := Vector2i(-1, -1)
  var position := Vector2i(-1, -1)

  func _init(position: Vector2i, source_id: int, tile_index: Vector2i) -> void:
    self.position = position
    self.source_id = source_id
    self.tile_index = tile_index

  static func enemy_config(task: Task, position: Vector2i) -> DrawConfig:
    return DrawConfig.new(position, enemy_source_id, enemy_tiles[GameWorld.get_enemy_index(task)])

  static func portal_config(project: Project, position: Vector2i) -> DrawConfig:
    var portal_tile_index: Vector2i =\
      portal_tiles[difficulty_to_portal_index[project.difficulty]] if not project.completed else portal_tiles[6]
    return DrawConfig.new(position, portal_source_id, portal_tile_index)

var enemies: Dictionary
var portals: Dictionary
# 1D array of non-occupied tile coordinates. Will be spliced (as in JS) when a task is added.
var free_tiles: Array[Vector2i] = []
var children: Dictionary
var parent: GameWorld = null
var project: Project = null
var size: GameWorldSize:
  set(new_size):
    size = new_size
    enemies.clear()
    portals.clear()
    free_tiles.clear()
    children.clear()
    for x in range(0, size.x, 3):
      for y in range(0, size.y, 2):
        free_tiles.append(Vector2i(x + 1, y))
    for x in range(0, size.remainder, 3):
      free_tiles.append(Vector2i(x + 1, size.y))
var task_screen: TaskoidScreenBase = null
var project_screen: ProjectScreen = null
var time_since_last_repeatable_check := repeatable_check_interval
var enemy_animation: TileAnimation = null
var current_enemy: Vector2i = Vector2(-1, -1)

static func new_game_world(project: Project, parent: GameWorld = null, position = Vector2i(-1, -1)) -> Result:
  var instance: GameWorld = GameWorldScene.instantiate()
  if project != null:
    instance.size = GameWorldSize.new(project.difficulty)
  instance.project = project
  instance.parent = parent
  instance.hide()
  if parent != null:
    if not parent.add_game_world(instance, position):
      instance.queue_free()
      return Result.Error("Couldn't add new game world to parent")
  return Result.new(instance)

static func find_game_world_for_taskoid(taskoid: RefCounted, default: GameWorld) -> GameWorld:
  return default if taskoid.parent == null else default.find_game_world(taskoid.parent)

static func mouse_position_to_tile_position(tilemap: TileMapLayer, mouse_position: Vector2, zoom: float) -> Vector2i:
  return Vector2i(
    -tilemap.position.x / tile_size.x + mouse_position.x / (tile_size.x * zoom),
    -tilemap.position.y / tile_size.y + mouse_position.y / (tile_size.y * zoom))

static func pixel_position_to_tile_position(tilemap: TileMapLayer, pixel_position: Vector2) -> Vector2i:
  return Vector2i(
    pixel_position.x / tile_size.x,
    pixel_position.y / tile_size.y
  )

static func get_enemy_index(task: Task) -> int:
  return difficulty_to_enemy_index[task.difficulty]

static func create_entity(taskoid: Taskoid) -> Entity:
  if taskoid.repetition_config:
    return RevivingEntity.new(taskoid)
  return MortalEntity.new(taskoid)

func _init(size := GameWorldSize.new(300)) -> void:
  self.size = size
  task_screen = TaskScreenScene.instantiate()
  task_screen.hide()
  project_screen = ProjectScreenScene.instantiate()
  project_screen.hide()

func _ready() -> void:
  add_child(task_screen)
  add_child(project_screen)
  if parent != null:
    exit_button.show()
  character.position = Vector2i(
    size.x / 2 * tile_size.x,
    size.y * tile_size.y - tile_size.y)
  character.arrived.connect(_on_character_arrived)
  for x in size.x:
    for y in size.y:
        draw_grass(Vector2i(x, y))
  for x in size.remainder:
      draw_grass(Vector2i(x, size.y))
      draw_grass(Vector2i(x, size.y + 1))
  # We try to draw enemies and portals in case they were added, when this GameWorld wasn't yet ready
  for position: Vector2i in enemies:
    var enemy: Entity = enemies[position]
    try_to_draw(enemy, DrawConfig.enemy_config(enemy.taskoid, position))
  for position: Vector2i in portals:
    var portal: Entity = portals[position]
    try_to_draw(portal, DrawConfig.portal_config(portal.taskoid, position))

func _unhandled_input(event: InputEvent) -> void:
  handle_mouse_buttons(get_pressed_mouse_buttons(event))
  if Input.is_action_pressed("ui_home"):
    tilemap.position = Vector2.ZERO
    camera.zoom = Vector2.ONE
  
func get_pressed_mouse_buttons(event: InputEvent) -> int:
  var buttons_pressed := 0
  var mouse_event = event as InputEventMouseButton
  if mouse_event:
    if mouse_event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
      buttons_pressed += mouse_btn_bit_values[MOUSE_BUTTON_WHEEL_DOWN]
    if mouse_event.button_index == MOUSE_BUTTON_WHEEL_UP:
      buttons_pressed += mouse_btn_bit_values[MOUSE_BUTTON_WHEEL_UP]
    if mouse_event.button_index == MOUSE_BUTTON_LEFT:
      buttons_pressed += mouse_btn_bit_values[MOUSE_BUTTON_LEFT]
    elif mouse_event.button_index == MOUSE_BUTTON_RIGHT:
      buttons_pressed += mouse_btn_bit_values[MOUSE_BUTTON_RIGHT]
  return buttons_pressed

func handle_left_mouse_button(tile_position: Vector2i, is_enemy: bool) -> void:
  var screen_size := task_screen.size if is_enemy else project_screen.size
  var screen_position := Vector2i(
      max(
        0,
        min(
          size.x * tile_size.x - screen_size.x,
          get_local_mouse_position().x - screen_size.x / 2)),
      max(
        0,
        min(
          size.y * tile_size.y - screen_size.y,
          get_local_mouse_position().y - screen_size.y / 2)))
  if is_enemy:
    task_screen.position = screen_position
    task_screen.set_taskoid(enemies[tile_position].taskoid)
    task_screen.show()
  else:
    project_screen.position = screen_position
    project_screen.set_taskoid(portals[tile_position].taskoid)
    project_screen.show()

func handle_mouse_wheel(buttons_pressed: int) -> void:
  const zoom_ratio := 1.1
  if buttons_pressed & mouse_btn_bit_values[MOUSE_BUTTON_WHEEL_DOWN]:
    camera.zoom /= zoom_ratio
  elif buttons_pressed & mouse_btn_bit_values[MOUSE_BUTTON_WHEEL_UP]:
    camera.zoom *= zoom_ratio

# Returns a Result, which contains true, if the clicked tile was an enemy, false, if it was a portal
# and an error if the clicked tile was neither.
# Also sends the character to the target tile, if it was an enemy or a portal.
func handle_character_movement(buttons_pressed: int, tile_position: Vector2i) -> Result:
  print("mouse_position %v tile_position %v" % [get_local_mouse_position(), tile_position])
  var is_enemy := enemies.has(tile_position)
  var is_portal := portals.has(tile_position)
  if (not is_enemy or enemies[tile_position].taskoid.completed)\
    and (not is_portal or portals[tile_position].taskoid.completed):
    return Result.Error("Not an entity")
  character.move_to_target(Vector2(
    tile_position.x * tile_size.x,
    (tile_position.y + (1 if is_enemy else 0)) * tile_size.y),
    true if buttons_pressed & MOUSE_BUTTON_MASK_RIGHT else false)
  return Result.new(is_enemy)

func handle_mouse_buttons(buttons_pressed: int) -> void:
  handle_mouse_wheel(buttons_pressed)
  var tile_position := mouse_position_to_tile_position(tilemap, get_local_mouse_position(), camera.zoom.x)
  if buttons_pressed:
    var is_enemy_result := handle_character_movement(buttons_pressed, tile_position)
    if buttons_pressed & mouse_btn_bit_values[MOUSE_BUTTON_LEFT] and not is_enemy_result.error.length():
      # Left click, show Taskoid Screen
      handle_left_mouse_button(tile_position, is_enemy_result.result)
      if is_enemy_result.result:
        enemy_animation = TileAnimation.new(enemy_animations[enemies[tile_position].taskoid.difficulty], 4)
        if current_enemy != Vector2i(-1, -1):
          # We reset the enemy that was animated before to it's idle image
          var entity: Entity = enemies[current_enemy];
          draw_taskoid(entity.taskoid.name, DrawConfig.enemy_config(entity.taskoid, current_enemy))
        current_enemy = tile_position
      else:
        enemy_animation = null
        current_enemy = Vector2i(-1, -1)
    elif buttons_pressed & mouse_btn_bit_values[MOUSE_BUTTON_RIGHT]:
      enemy_animation = null
      current_enemy = Vector2i(-1, -1)

func _notification(what: int) -> void:
  if what == NOTIFICATION_PREDELETE:
    for position: Vector2i in children:
      children[position].queue_free()
    task_screen.queue_free()
    project_screen.queue_free()

func _process(delta: float) -> void:
  time_since_last_repeatable_check += delta
  if time_since_last_repeatable_check >= repeatable_check_interval:
    advance_repeatables()
    display_repeatables()
    time_since_last_repeatable_check = 0
  const disposition := 10
  if Input.is_action_pressed("ui_left"):
    tilemap.position.x -= disposition
  if Input.is_action_pressed("ui_right"):
    tilemap.position.x += disposition
  if Input.is_action_pressed("ui_up"):
    tilemap.position.y -= disposition
  if Input.is_action_pressed("ui_down"):
    tilemap.position.y += disposition
  animate_enemy(delta)

func advance_repeatables() -> void:
  for position in portals:
    var portal: Entity = portals[position]
    if not portal is RevivingEntity:
      continue
    if portal.should_be_advanced():
      portal.taskoid.advance()
  for position in enemies:
    var enemy: Entity = enemies[position]
    if enemy.should_be_advanced():
      enemy.taskoid.advance()

func display_repeatables() -> void:
  for position in portals:
    var portal: Entity = portals[position]
    if not portal is RevivingEntity:
      continue
    try_to_draw(portal, DrawConfig.portal_config(portal.taskoid, position))
  for position in enemies:
    var enemy: Entity = enemies[position]
    if not enemy is RevivingEntity:
      continue
    try_to_draw(enemy, DrawConfig.enemy_config(enemy.taskoid, position))

func try_to_draw(entity: Entity, config: DrawConfig) -> void:
  if not entity.should_be_drawn():
    return
  if draw_taskoid(entity.taskoid.name, config):
    entity.on_draw()

func add_monster(task: Task, position = Vector2i(-1, -1)) -> bool:
  var tile_position: Vector2i
  if free_tiles.is_empty():
    return false
  elif position != Vector2i(-1, -1):
    tile_position = position
  else:
    tile_position = reserve_random_free_tile()
  task.done.connect(_on_task_done)
  enemies[tile_position] = create_entity(task)
  # We try to draw in case a task is added, when this GameWorld is ready
  try_to_draw(enemies[tile_position], DrawConfig.enemy_config(task, tile_position))
  return true

func remove_monster(task: Task) -> bool:
  for position: Vector2i in enemies:
    if enemies[position].taskoid == task:
      free_tiles.append(position)
      enemies.erase(position)
      draw_grass(position)
      return true
  return false

func add_game_world(child: GameWorld, position = Vector2i(-1, -1)) -> bool:
  var tile_position: Vector2i
  if free_tiles.is_empty():
    return false
  elif position != Vector2i(-1, -1):
    tile_position = position
  else:
    tile_position = reserve_random_free_tile()
  children[tile_position] = child
  portals[tile_position] = create_entity(child.project)
  try_to_draw(portals[tile_position], DrawConfig.portal_config(child.project, tile_position))
  return true

func remove_game_world(child: GameWorld) -> void:
  for position: Vector2i in children:
    if children[position] == child:
      free_tiles.append(position)
      portals.erase(position)
      draw_grass(position)
      children.erase(child)
      return

func mark_portal_done(project: Project) -> void:
  if portals.is_empty():
    return
  for position: Vector2i in portals:
    if portals[position].taskoid == project:
      tilemap.set_cell(position, portal_source_id, portal_tiles[6])

func find_game_world(project: Project) -> GameWorld:
  if self.project == project:
    return self
  for position: Vector2i in children:
    var child: GameWorld = children[position]
    if child.project == project:
      return child
    
  for position: Vector2i in children:
    var child: GameWorld = children[position]
    var found := child.find_game_world(project)
    if found != null:
      return found
  return null

func reserve_random_free_tile() -> Vector2i:
  var free_tile: Vector2i = free_tiles.pick_random()
  free_tiles.erase(free_tile)
  return free_tile

func draw_taskoid(name: String, config: DrawConfig) -> bool:
  if tilemap != null:
    tilemap.set_cell(config.position, config.source_id, config.tile_index)
    add_label_for_taskoid(name, config.position)
    return true
  return false

func draw_grass(position: Vector2i) -> void:
  if tilemap == null:
    return
  var rng := RandomNumberGenerator.new()
  var grass_tile_index := 0 if rng.randi_range(0, 6) < 3 else 1
  tilemap.set_cell(position, grass_source_id, grass_tiles[grass_tile_index])

func _on_character_arrived(at: Vector2) -> void:
  var tile_position := pixel_position_to_tile_position(tilemap, at)
  var enemy_tile_pos := Vector2i(tile_position.x, tile_position.y - 1)
  if portals.has(tile_position):
    open_game_world.emit(children[tile_position])
  elif enemies.has(enemy_tile_pos):
    var enemy: Entity = enemies[enemy_tile_pos]
    enemy.taskoid.complete()

func _on_exit_button_pressed() -> void:
  if parent != null:
    open_game_world.emit(parent)
  else:
    Globals.show_error_screen("Exit button pressed on game world, that doesn't have parent")

func _on_task_done(task: Task) -> void:
  # TODO: replace the texture with a dead texture
  for position: Vector2i in enemies:
    var enemy: Entity = enemies[position]
    if enemy.taskoid == task:
      if current_enemy == position:
        enemy_animation = null
        current_enemy = Vector2i(-1, -1)
      draw_grass(position)
      remove_label_for_taskoid(task, position)
      enemy.on_hide()

func _on_project_done(project: Project) -> void:
  mark_portal_done(project)
  for position: Vector2i in portals:
    var portal: Entity = portals[position]
    if portal.taskoid == project:
      portal.on_hide()

func add_label_for_taskoid(name: String, tile_pos: Vector2i) -> void:
  var label := Label.new()
  # This is needed because the _ready function was not yet called here probably and we still need
  # access to the tilemap.
  var tilemap := self.get_node(^"SubViewportContainer/GameViewport/TileMapLayer")
  tilemap.add_child(label)
  tilemap.move_child(label, -3)
  label.text = name
  label.clip_text = true
  label.size = Vector2(tile_size.x * 3, tile_size.y)
  label.position = tile_pos * tile_size
  label.position.x -= tile_size.x
  label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
  label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
  label.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS

func remove_label_for_taskoid(taskoid: Taskoid, tile_pos: Vector2i) -> void:
  var tilemap := self.get_node(^"SubViewportContainer/GameViewport/TileMapLayer")
  var tilemap_children := tilemap.get_children()
  for child in tilemap_children:
    if child is Label:
      var label := child as Label
      if label.text == taskoid.name\
        # We have to adjust the tile position, because the label takes up 3 tiles, so it's position
        # is one tile to the left of the clicked tile
        and label.position == Vector2(tile_pos * tile_size - Vector2i(64, 0)):
        tilemap.remove_child(child)
        child.queue_free()

func to_dict() -> Dictionary:
  var dict: Dictionary
  dict[MainGameScene.tasks_key] = {}
  dict[MainGameScene.projects_key] = {}
  for position in enemies:
    var monster: Entity = enemies[position]
    var monster_dict: Dictionary = monster.taskoid.config().to_dict()
    monster_dict[position_key] = position
    dict[MainGameScene.tasks_key][monster.taskoid.name] = monster_dict
  for position in portals:
    var portal: Entity = portals[position]
    var portal_dict: Dictionary = portal.taskoid.config().to_dict()
    portal_dict[position_key] = position
    dict[MainGameScene.projects_key][portal.taskoid.name] = portal_dict
  for position in children:
    var child: GameWorld = children[position]
    var child_dict: Dictionary = child.to_dict()
    dict[MainGameScene.tasks_key].merge(child_dict[MainGameScene.tasks_key])
    dict[MainGameScene.projects_key].merge(child_dict[MainGameScene.projects_key])
  return dict

func animate_enemy(delta: float) -> void:
  if current_enemy == Vector2i(-1, -1) or not enemy_animation:
    return
  tilemap.set_cell(current_enemy, enemy_source_id, enemy_animation.animate(delta))

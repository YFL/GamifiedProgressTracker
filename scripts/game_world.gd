class_name GameWorld extends Node2D

signal open_game_world(game_world: GameWorld)

@onready var tilemap: TileMapLayer = $TileMapLayer
@onready var tileset: TileSet = tilemap.tile_set
@onready var character: Character = $Character
@onready var exit_button: TextureButton = $ExitButton

const grass_tiles := [Vector2i(0, 0), Vector2i(1, 0)]
const enemy_tiles := [Vector2i(0, 0), Vector2i(0, 1), Vector2i(1, 0), Vector2i(1, 1),
  Vector2i(2, 0)]
const portal_tiles := [Vector2i(0, 0), Vector2i(1, 0), Vector2i(2, 0), Vector2i(3, 0), Vector2i(4, 0), Vector2i(5, 0), Vector2i(6, 0)]
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

static func pixel_position_to_tile_position(pixel_position: Vector2) -> Vector2i:
  return Vector2i(pixel_position.x / tile_size.x, pixel_position.y / tile_size.y)

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
  var mouse_button_pressed := 0
  if event.is_action_pressed("ui_left_click"):
    mouse_button_pressed += MOUSE_BUTTON_LEFT
  elif event.is_action_pressed("ui_right_click"):
    mouse_button_pressed += MOUSE_BUTTON_RIGHT
  if mouse_button_pressed:
    var tile_position := pixel_position_to_tile_position(get_local_mouse_position())
    var is_enemy := enemies.has(tile_position)
    var is_portal := portals.has(tile_position)
    if not is_enemy and not is_portal:
      return
    var notify := true if mouse_button_pressed & MOUSE_BUTTON_MASK_RIGHT else false
    character.move_to_target(Vector2(
      tile_position.x * tile_size.x,
      (tile_position.y + (1 if is_enemy else 0)) * tile_size.y),
      notify)
    # Left click, show Taskoid Screen
    if not notify:
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
      elif is_portal:
        project_screen.position = screen_position
        project_screen.set_taskoid(portals[tile_position].taskoid)
        project_screen.show()

func _notification(what: int) -> void:
  if what == NOTIFICATION_PREDELETE:
    for position: Vector2i in children:
      children[position].queue_free()
    task_screen.queue_free()
    project_screen.queue_free()

func _process(delta: float) -> void:
  time_since_last_repeatable_check += delta
  if time_since_last_repeatable_check >= repeatable_check_interval:
    display_repeatables()
    time_since_last_repeatable_check = 0

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
  draw_taskoid(config)
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
  add_label_for_taskoid(task, tile_position)
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
  add_label_for_taskoid(child.project, tile_position)
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

func draw_taskoid(config: DrawConfig) -> void:
  if tilemap != null:
    tilemap.set_cell(config.position, config.source_id, config.tile_index)

func draw_grass(position: Vector2i) -> void:
  if tilemap == null:
    return
  var rng := RandomNumberGenerator.new()
  var grass_tile_index := 0 if rng.randi_range(0, 6) < 3 else 1
  tilemap.set_cell(position, grass_source_id, grass_tiles[grass_tile_index])

func _on_character_arrived(at: Vector2) -> void:
  var tile_position := pixel_position_to_tile_position(at)
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
  pass

func _on_project_done(project: Project) -> void:
  mark_portal_done(project)

func add_label_for_taskoid(taskoid: Taskoid, tile_pos: Vector2i) -> void:
  var label := Label.new()
  add_child(label)
  move_child(label, -3)
  label.text = taskoid.name
  label.clip_text = true
  label.size = Vector2(tile_size.x * 3, tile_size.y)
  label.position = tile_pos * tile_size
  label.position.x -= tile_size.x
  label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
  label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
  label.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS

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

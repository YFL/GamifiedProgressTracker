class_name GameWorld extends Node2D

@onready var tilemap: TileMapLayer = $TileMapLayer
@onready var tileset: TileSet = tilemap.tile_set
@onready var character: Character = $Character
@onready var exit_button: TextureButton = $ExitButton

const grass_tiles := [Vector2i(0, 0), Vector2i(1, 0)]
const enemy_tiles := [Vector2i(0, 0), Vector2i(0, 1), Vector2i(1, 0), Vector2i(1, 1)]
const portal_tiles := [Vector2i(0, 0), Vector2i(1, 0)]
const grass_source_id := 0
const enemy_source_id := 1
const portal_source_id := 2
const tile_size = Vector2i(64, 64)
const difficulty_to_enemy_index := {
  Difficulty.Modest: 0,
  Difficulty.NoteWorthy: 1,
  Difficulty.Commendable: 2,
  Difficulty.Glorious: 3,
  Difficulty.Heroic: 3,
  Difficulty.Majestic: 3,
  Difficulty.Legendary: 3,
  Difficulty.Imperial: 3,
  Difficulty.Supreme: 3,
  Difficulty.Transcendent: 3
}

const position_key := "position"

const GameWorldScene := preload("res://scenes/GameWorld.tscn")
const TaskScreenScene := preload("res://scenes/TaskScreen.tscn")
const ProjectScreenScene := preload("res://scenes/ProjectScreen.tscn")

class Enemy extends RefCounted:
  var task: Task

  func _init(task: Task):
    self.task = task

class Portal extends RefCounted:
  var game_world: GameWorld

  func _init(game_world: GameWorld):
    self.game_world = game_world

class GameWorldSize extends RefCounted:
  var x := 0
  var y := 0
  var remainder := 0

  func _init(difficulty: int):
    difficulty = difficulty / Difficulty.Modest
    var square := int(sqrt(difficulty))
    var best_difficulty_diff := difficulty - square * square
    var best_dimension_diff := square - (difficulty - square)
    if best_dimension_diff < 0:
      best_dimension_diff *= -1
    for width in range(square, difficulty + 1):
      var height := difficulty / width
      var diff := difficulty - width * height
      var dimension_diff := width - height
      if dimension_diff < 0:
        dimension_diff *= -1
      if diff <= best_difficulty_diff and dimension_diff <= best_dimension_diff:
        x = width
        y = height
        best_difficulty_diff = diff
      if diff == 0:
        break
    if x < y:
      var tmp := x;
      x = y
      y = tmp
    if difficulty != x * y:
      remainder = difficulty - x * y
    x *= 3
    y *= 2
    remainder *= 3

var enemies: Dictionary
var portals: Dictionary
# 1D array of non-occupied tile coordinates. Will be spliced (as in JS) when a task is added.
var free_tiles: Array[Vector2i] = []
var children: Array[GameWorld] = []
var parent: GameWorld = null
var project: Project = null
var selected_child: GameWorld = null
var size: GameWorldSize:
  set(new_size):
    size = new_size
    enemies.clear()
    portals.clear()
    free_tiles.clear()
    children.clear()
    selected_child = null
    for x in range(0, size.x, 3):
      for y in range(0, size.y, 2):
        free_tiles.append(Vector2i(x + 1, y))
    for x in range(0, size.remainder, 3):
      free_tiles.append(Vector2i(x + 1, size.y))
var task_screen: TaskScreen = null
var project_screen: ProjectScreen = null

static func new_game_world(project: Project, parent: GameWorld = null, position = Vector2i(-1, -1)) -> Result:
  var instance: GameWorld = GameWorldScene.instantiate()
  if project != null:
    instance.size = GameWorldSize.new(project.capacity)
  instance.project = project
  instance.parent = parent
  instance.hide()
  if parent != null:
    if not parent.add_game_world(instance, position):
      instance.queue_free()
      return Result.new(null, "Couldn't add new game world to parent")
  return Result.new(instance)

static func find_game_world_for_taskoid(taskoid: RefCounted, default: GameWorld) -> GameWorld:
  return default if taskoid.parent == null else default.find_game_world(taskoid.parent)

static func pixel_position_to_tile_position(pixel_position: Vector2) -> Vector2i:
  return Vector2i(pixel_position.x / tile_size.x, pixel_position.y / tile_size.y)

static func get_enemy_index(task: Task) -> int:
  return difficulty_to_enemy_index[task.difficulty]

func _init(size := GameWorldSize.new(300)) -> void:
  self.size = size
  task_screen = TaskScreenScene.instantiate()
  project_screen = ProjectScreenScene.instantiate()

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
    draw_taskoid(position, enemy_source_id, enemy_tiles[get_enemy_index(enemies[position].task)])
  for position: Vector2i in portals:
    var portal_tile_index :=\
      portal_tiles[0] if portals[position].game_world.project.completed else portal_tiles[1]
    draw_taskoid(position, portal_source_id, portal_tile_index)

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
    character.move_to_target(Vector2(tile_position.x * tile_size.x, (tile_position.y + 1)* tile_size.y), notify)
    # Left click, show Taskoid Screen
    if not notify:
      var screen_position := Vector2i(
          max(
            0,
            min(
              size.x * tile_size.x - task_screen.size.x,
              get_local_mouse_position().x - task_screen.size.x / 2)),
          max(
            0,
            min(
              size.y * tile_size.y - task_screen.size.y,
              get_local_mouse_position().y - task_screen.size.y / 2)))
      if is_enemy:
        task_screen.position = screen_position
        var task: Task = enemies[tile_position].task
        task_screen.set_task(task)
        task_screen.show()
      elif is_portal:
        project_screen.position = screen_position
        project_screen.project = portals[tile_position].game_world.project
        project_screen.show()

func _notification(what: int) -> void:
  if what == NOTIFICATION_PREDELETE:
    for child: GameWorld in children:
      child.queue_free()
    task_screen.queue_free()
    project_screen.queue_free()

func add_monster(task: Task, position = Vector2i(-1, -1)) -> bool:
  var tile_position: Vector2i
  if position != Vector2i(-1, -1):
    tile_position = position
  elif free_tiles.is_empty():
    return false
  else:
    tile_position = reserve_random_free_tile()
  task.done.connect(_on_task_done)
  enemies[tile_position] = Enemy.new(task)
  # We try to draw in case a task is added, when this GameWorld is ready
  draw_taskoid(tile_position, enemy_source_id, enemy_tiles[get_enemy_index(task)])
  add_label_for_taskoid(task, tile_position)
  return true

func remove_monster(task: Task) -> bool:
  if enemies.is_empty():
    return false;
  for position: Vector2i in enemies:
    if enemies[position].task == task:
      free_tiles.append(position)
      enemies.erase(position)
      draw_grass(position)
      return true
  return false

func add_game_world(child: GameWorld, position = Vector2i(-1, -1)) -> bool:
  var tile_position: Vector2i
  if position != Vector2i(-1, -1):
    tile_position = position
  elif free_tiles.is_empty():
    return false
  else:
    tile_position = reserve_random_free_tile()
  children.append(child)
  portals[tile_position] = Portal.new(child)
  draw_taskoid(tile_position, portal_source_id, portal_tiles[0])
  add_label_for_taskoid(child.project, tile_position)
  return true

func remove_game_world(child: GameWorld) -> void:
  if portals.is_empty():
    return
  for position: Vector2i in portals:
    if portals[position].game_world == child:
      free_tiles.append(position)
      portals.erase(position)
      draw_grass(position)
      children.erase(child)
      return

func mark_portal_done(project: Project) -> void:
  if portals.is_empty():
    return
  for position: Vector2i in portals:
    if portals[position].game_world.project == project:
      tilemap.set_cell(position, portal_source_id, portal_tiles[1])

func find_game_world(project: Project) -> GameWorld:
  if self.project == project:
    return self
  for child: GameWorld in children:
    if child.project == project:
      return child
    
  for child: GameWorld in children:
    var found := child.find_game_world(project)
    if found != null:
      return found
    
  return null

func reserve_random_free_tile() -> Vector2i:
  var free_tile: Vector2i = free_tiles.pick_random()
  free_tiles.erase(free_tile)
  return free_tile

func draw_taskoid(position: Vector2i, source_id: int, tile_index: Vector2i) -> void:
  if tilemap != null:
    tilemap.set_cell(position, source_id, tile_index)

func draw_grass(position: Vector2i) -> void:
  if tilemap == null:
    return
  var rng := RandomNumberGenerator.new()
  var grass_tile_index := 0 if rng.randi_range(0, 6) < 3 else 1
  tilemap.set_cell(position, grass_source_id, grass_tiles[grass_tile_index])

func _on_character_arrived(at: Vector2) -> void:
  var tile_position := pixel_position_to_tile_position(at)
  if enemies.has(tile_position):
    var enemy: Enemy = enemies[tile_position]
    enemy.task.complete()
  elif portals.has(tile_position):
    var portal: Portal = portals[tile_position]
    if selected_child != null:
      remove_child(selected_child)
    add_child(portal.game_world)
    selected_child = portal.game_world
    selected_child.show()
    tilemap.hide()
    character.hide()
    exit_button.hide()

func _on_exit_button_pressed() -> void:
  hide()
  if parent != null:
    parent.remove_child(self)
    parent.selected_child = null
    parent.tilemap.show()
    parent.character.show()
    if parent.parent != null:
      parent.exit_button.show()

func _on_task_done(task: Task) -> void:
  remove_monster(task)

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
    var monster: Enemy = enemies[position]
    var monster_dict: Dictionary = monster.task.to_dict()
    monster_dict[position_key] = position
    dict[MainGameScene.tasks_key][monster.task.name] = monster_dict
  for position in portals:
    var portal: Portal = portals[position]
    var portal_dict: Dictionary = portal.game_world.project.to_dict()
    portal_dict[position_key] = position
    dict[MainGameScene.projects_key][portal.game_world.project.name] = portal_dict
  for child in children:
    var child_dict: Dictionary = child.to_dict()
    dict[MainGameScene.tasks_key].merge(child_dict[MainGameScene.tasks_key])
    dict[MainGameScene.projects_key].merge(child_dict[MainGameScene.projects_key])
  return dict

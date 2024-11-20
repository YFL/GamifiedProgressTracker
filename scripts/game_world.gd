class_name GameWorld extends Node2D

@onready var tilemap: TileMapLayer = $TileMapLayer
@onready var tileset: TileSet = tilemap.tile_set
@onready var character: Character = $Character

const grass_tiles := [Vector2i(0, 0), Vector2i(1, 0)]
const enemy_tiles := [Vector2i(0, 0), Vector2i(0, 1), Vector2i(1, 0), Vector2i(1, 1)]
const grass_source_id := 0
const enemy_source_id := 1
const size := Vector2i(20, 11)
const tile_size = Vector2i(64, 64)
const difficulty_to_enemy_index := {
  Task.TaskDifficulty.Easy: 0,
  Task.TaskDifficulty.Medium: 1,
  Task.TaskDifficulty.Hard: 2,
  Task.TaskDifficulty.Gigantic: 3,
}

class Enemy extends RefCounted:
  var task: Task

  func _init(task: Task):
    self.task = task

var enemies: Dictionary
# 1D array of non-occupied tile coordinates. Will be spliced (as in JS) when a task is added.
var free_tiles: Array[Vector2i]

static func pixel_position_to_tile_position(pixel_position: Vector2) -> Vector2i:
  return Vector2i(pixel_position.x / tile_size.x, pixel_position.y / tile_size.y)

func _ready() -> void:
  character.position = Vector2i(
    size.x / 2 * tile_size.x,
    size.y * tile_size.y - tile_size.y)
  character.arrived.connect(_on_character_arrived)
  var rng := RandomNumberGenerator.new()
  for x in size.x:
    for y in size.y:
      free_tiles.append(Vector2i(x, y))
      var grass_tile_index := 0 if rng.randi_range(0, 6) < 1 else 1
      tilemap.set_cell(Vector2i(x, y), grass_source_id, grass_tiles[grass_tile_index])

func _process(delta: float) -> void:
  var mouse_button_pressed := 0
  if Input.is_action_just_pressed("ui_left_click"):
    mouse_button_pressed += MOUSE_BUTTON_LEFT
  elif Input.is_action_just_pressed("ui_right_click"):
    mouse_button_pressed += MOUSE_BUTTON_RIGHT
  if mouse_button_pressed:
    var tile_position := pixel_position_to_tile_position(get_local_mouse_position())
    if not enemies.has(tile_position):
      return
    var notify := true if mouse_button_pressed & MOUSE_BUTTON_MASK_RIGHT else false
    character.move_to_target(Vector2(tile_position.x * tile_size.x, tile_position.y * tile_size.y), notify)
  # If clicked on monster move character to monster if not already there
  # If clicked on monster move character to monster if not already there and complete task

func add_monster(task: Task) -> bool:
  if free_tiles.is_empty():
    return false
  var enemy_index: int = difficulty_to_enemy_index[task.combined_difficulty]
  var free_tile: Vector2i = free_tiles.pick_random()
  free_tiles.erase(free_tile)
  tilemap.set_cell(free_tile, enemy_source_id, enemy_tiles[enemy_index])
  enemies[free_tile] = Enemy.new(task)
  return true

func remove_monster(task: Task) -> bool:
  if enemies.is_empty():
    return false;
  for position: Vector2i in enemies:
    if enemies[position].task == task:
      free_tiles.append(position)
      enemies.erase(position)
      return true
  return false

func _on_character_arrived(at: Vector2) -> void:
  var tile_position := pixel_position_to_tile_position(at)
  if not enemies.has(tile_position):
    return
  var enemy: Enemy = enemies[tile_position]
  enemy.task.complete()
  remove_monster(enemy.task)

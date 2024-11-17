class_name GameWorld extends Node2D

@onready var tilemap: TileMapLayer = $TileMapLayer
@onready var tileset: TileSet = tilemap.tile_set

const grass_tiles := [Vector2i(0, 0), Vector2i(1, 0)]
const enemy_tiles := [Vector2i(0, 0), Vector2i(0, 1), Vector2i(1, 0), Vector2i(1, 1)]
const grass_source_id := 0
const enemy_source_id := 1
const size := Vector2i(20, 11)

class Enemy extends RefCounted:
  var position: Vector2i
  var task: Task

  func _init(position: Vector2i, task: Task):
    self.position = position
    self.task = task

var enemies: Array[Enemy]
# 1D array of non-occupied tile coordinates. Will be spliced (as in JS) when a task is added.
var free_tiles: Array[Vector2i]

func _ready() -> void:
  var rng := RandomNumberGenerator.new()
  for x in size.x:
    for y in size.y:
      free_tiles.append(Vector2i(x, y))
      var grass_tile_index := 0 if rng.randi_range(0, 6) < 1 else 1
      tilemap.set_cell(Vector2i(x, y), grass_source_id, grass_tiles[grass_tile_index])

func add_monster(task: Task) -> bool:
  if free_tiles.is_empty():
    return false
  var rng := RandomNumberGenerator.new()
  var enemy_index := rng.randi_range(0, len(enemy_tiles) - 1)
  var free_tile: Vector2i = free_tiles.pick_random()
  free_tiles.erase(free_tile)
  tilemap.set_cell(free_tile, enemy_source_id, enemy_tiles[enemy_index])
  enemies.append(Enemy.new(free_tile, task))
  return true

func remove_monster(task: Task) -> bool:
  if enemies.is_empty():
    return false;
  for enemy: Enemy in enemies:
    if enemy.task == task:
      free_tiles.append(enemy.position)
      enemies.erase(enemy)
      return true
  return false

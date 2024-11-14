class_name GameWorld extends Node2D

@onready var tilemap: TileMapLayer = $TileMapLayer

const terrain_atlas_coord := Vector2i(0, 0)
const size := Vector2i(1280, 720)

func _ready() -> void:
  var tileset := tilemap.tile_set
  print("Source count: " + str(tileset.get_source_count()))
  for i: int in tileset.get_source_count():
    print("Id of source #" + str(i) + ": " + str(tileset.get_source_id(i)))
  
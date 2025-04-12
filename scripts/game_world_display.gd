class_name GameWorldDisplay extends Node2D

var _game_world: GameWorld = null

func set_game_world(game_world: GameWorld) -> void:
  _remove_game_world()
  _game_world = game_world
  add_child(_game_world)
  _game_world.show()

func game_world() -> GameWorld:
  return _game_world

func reset() -> void:
  _remove_game_world()
  _game_world = null

func _remove_game_world() -> void:
  if _game_world:
    remove_child(_game_world)
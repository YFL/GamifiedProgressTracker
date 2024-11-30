extends GdUnitTestSuite

const GameWorldScene = preload("res://scenes/GameWorld.tscn")
const task_names: Array[String] = ["a", "b", "c", "d"]
var game_world
var test_tasks: Array[Task]
var difficulties: Array[int]

func _init() -> void:
  # We leave out Invalid
  for i: int in range(1, Difficulty.difficulty_names.keys().size()):
    difficulties.append(Difficulty.string_to_difficulty(Difficulty.difficulty_names.values()[i]))
  for i: int in task_names.size():
    test_tasks.append(Task.new(task_names[i], null, false, difficulties[i]))

func before() -> void:
  game_world = scene_runner(auto_free(GameWorldScene.instantiate()))
  for task: Task in test_tasks:
    game_world.scene().add_monster(task)

func test_create_task():
  assert_array(game_world.scene().enemies.keys())\
    .has_size(test_tasks.size())
  var non_free_tiles: Array[Vector2i]
  for position: Vector2i in game_world.scene().enemies:
    var enemy: GameWorld.Enemy = game_world.scene().enemies[position]
    non_free_tiles.append(position)
    assert_vector(position)\
      .is_between(Vector2i(0, 0), game_world.scene().size)
    assert_object(enemy.task)\
      .is_not_null()
  assert_array(game_world.scene().free_tiles)\
    .has_size(game_world.scene().size.x * game_world.scene().size.y - task_names.size())\
    .not_contains(non_free_tiles)
  
func test_remove_task() -> void:
  var enemies = game_world.scene().enemies.duplicate(true)
  assert_array(test_tasks).has_size(4)
  for task: Task in test_tasks:
    game_world.scene().remove_monster(task)
  test_tasks.all(func (task: Task): game_world.scene().remove_monster(task))
  assert_dict(game_world.scene().enemies)\
    .is_empty()
  assert_array(game_world.scene().free_tiles)\
    .has_size(game_world.scene().size.x * game_world.scene().size.y)\
    .contains(enemies.keys())

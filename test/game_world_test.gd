extends GdUnitTestSuite

const task_names: Array[String] = ["a", "b", "c", "d"]
var game_world: GameWorld
var test_tasks: Array[Task]
var difficulties: Array[Task.TaskDifficulty]

func _init() -> void:
  # We leave out Invalid
  for i: int in range(1, Task.task_difficulty_names.size()):
    difficulties.append(Task.string_to_task_difficulty(Task.task_difficulty_names.values()[i]))
  for i: int in task_names.size():
    test_tasks.append(Task.new(task_names[i], null, false, difficulties[i]))

func before() -> void:
  game_world = auto_free(GameWorld.new())
  for task: Task in test_tasks:
    game_world.add_monster(task)

func test_create_task():
  assert_array(game_world.enemies)\
    .has_size(test_tasks.size())
  var non_free_tiles: Array[Vector2i]
  for enemy: GameWorld.Enemy in game_world.enemies:
    non_free_tiles.append(enemy.position)
    assert_vector(enemy.position)\
      .is_between(Vector2i(0, 0), game_world.size)
    assert_object(enemy.task)\
      .is_not_null()
  assert_array(game_world.free_tiles)\
    .has_size(game_world.size.x * game_world.size.y - task_names.size())\
    .not_contains(non_free_tiles)
  
func test_remove_task() -> void:
  var enemies := game_world.enemies.duplicate(true)
  test_tasks.all(func (task: Task): game_world.remove_monster(task))
  assert_array(game_world.enemies)\
    .is_empty()
  assert_array(game_world.free_tiles)\
    .has_size(game_world.size.x * game_world.size.y)\
    .contains(enemies.map(func (enemy: GameWorld.Enemy): return enemy.position))

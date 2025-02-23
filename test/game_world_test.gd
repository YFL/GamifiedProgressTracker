extends GdUnitTestSuite

const GameWorldScene = preload("res://scenes/GameWorld.tscn")
var game_world
const task_names: Array[String] = ["a", "b", "c", "d"]
var test_projects: Array[Project] # Gigantic, Hard, Medium
var test_tasks: Array[Task]       # Hard,     Hard, Medium, Easy
var difficulties: Array[int]      # Gigantic, Hard, Medium, Easy

func _init() -> void:
  # We leave out Invalid
  for i: int in range(Difficulty.difficulty_names.keys().size() - 1, 0, -1):
    difficulties.append(Difficulty.string_to_difficulty(Difficulty.difficulty_names.values()[i]))
  for i: int in range(0, 3):
    var parent := null if i == 0 else test_projects[i - 1]
    test_projects.append(Project.new(task_names[i], task_names[i], parent, difficulties[i]))
  for i: int in task_names.size():
    var parent_index := i if i < test_projects.size() else test_projects.size() - 1
    var difficulty_index := i if i > 0 else 1
    test_tasks.append(
      Task.new(task_names[i], task_names[i], test_projects[parent_index], difficulties[difficulty_index]))

func before_test() -> void:
  game_world = scene_runner(auto_free(GameWorldScene.instantiate()))
  for project: Project in test_projects:
    GameWorld.new_game_world(
      project,
      GameWorld.find_game_world_for_taskoid(project, game_world.scene()))
  for task: Task in test_tasks:
    GameWorld.find_game_world_for_taskoid(task, game_world.scene()).add_monster(task)

func test_game_world_size() -> void:
  var game_world_size := GameWorld.GameWorldSize.new(Difficulty.NoteWorthy)
  assert_int(game_world_size.x).is_equal(3)
  assert_int(game_world_size.y).is_equal(2)
  assert_int(game_world_size.remainder).is_equal(0)
  game_world_size = GameWorld.GameWorldSize.new(2200)
  assert_int(game_world_size.x).is_equal(20)
  assert_int(game_world_size.y).is_equal(11)
  assert_int(game_world_size.remainder).is_equal(0)

func test_create_task():
  var game_world: GameWorld = game_world.scene().children[0]
  assert_array(game_world.enemies.keys())\
    .has_size(1)
  var non_free_tiles: Array[Vector2i]
  for position: Vector2i in game_world.enemies:
    var enemy: GameWorld.Enemy = game_world.enemies[position]
    non_free_tiles.append(position)
    position_tester(position, game_world.size)
    assert_object(enemy.task)\
      .is_not_null()
  assert_array(game_world.free_tiles)\
    # - 2 because 1 portal + 1 enemy
    .has_size(game_world.size.x * game_world.size.y + game_world.size.remainder - game_world.enemies.size() - game_world.portals.size())\
    .not_contains(non_free_tiles)
  
func test_remove_task() -> void:
  var game_world: GameWorld = game_world.scene().children[0]
  var enemies = game_world.enemies.duplicate(true)
  assert_array(test_tasks).has_size(4)
  test_tasks.all(func (task: Task): game_world.remove_monster(task))
  assert_dict(game_world.enemies)\
    .is_empty()
  assert_array(game_world.free_tiles)\
    # - 1 becuase of the portal
    .has_size(game_world.size.x * game_world.size.y - 1)\
    .contains(enemies.keys())

func test_create_project():
  var game_world: GameWorld = game_world.scene()
  create_project_tester(game_world, 1, game_world.size.x * game_world.size.y - 1)
  var iterator: GameWorld = game_world.children[0]
  create_project_tester(iterator, 1, iterator.size.x * iterator.size.y - 2)
  iterator = iterator.children[0]
  create_project_tester(iterator, 1, iterator.size.x * iterator.size.y - 2)
  iterator = iterator.children[0]
  # There are 2 enemies in this one
  create_project_tester(iterator, 0, iterator.size.x * iterator.size.y - 2)

func test_remove_project():
  # Since the remove game_world from the middle of the chaing functionality is not yet decided
  # and implemented, we won't write a test yet.
  var child: GameWorld = game_world.scene().children[0].children[0]
  var parent: GameWorld = game_world.scene().children[0]
  parent.remove_game_world(child)
  child.queue_free()
  assert_dict(parent.portals).has_size(0)
  assert_array(parent.children).has_size(0)
  # Since a monster is still in there, the free tiles is not fully loaded.
  assert_array(parent.free_tiles).has_size(parent.size.x * parent.size.y - 1)

func create_project_tester(
  game_world: GameWorld,
  expected_children_size: int,
  expected_free_tiles_size: int) -> void:
  assert_array(game_world.children).has_size(expected_children_size)
  assert_dict(game_world.portals).has_size(game_world.children.size())
  assert_array(game_world.free_tiles).has_size(expected_free_tiles_size)
  if expected_children_size > 0:
    var portal_position: Vector2i = game_world.portals.keys()[0]
    var portal: GameWorld.Portal = game_world.portals[game_world.portals.keys()[0]]
    assert_object(game_world.children[0])\
      .is_not_null()\
      .is_same(portal.game_world)
    assert_object(game_world.children[0].parent).is_same(game_world)
    assert_object(game_world.children[0].project.parent).is_same(game_world.project)
    position_tester(portal_position, game_world.size)
    assert_array(game_world.free_tiles).not_contains([portal_position])
    
func position_tester(position: Vector2i, game_world_size: GameWorld.GameWorldSize) -> void:
  assert_vector(position)\
      .is_between(
        Vector2i(0, 0),
        Vector2i(
          game_world_size.x * 3,
          game_world_size.y * 2 + (2 if game_world_size.remainder != 0 else 0)))
  if game_world_size.remainder != 0:
    assert_vector(position).is_not_between(
      Vector2i(game_world_size.remainder * 3, game_world_size.y + 2),
      Vector2i(game_world_size.x * 3, game_world_size.y + 2))
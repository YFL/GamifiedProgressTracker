extends GdUnitTestSuite

class Utils extends RefCounted:
  var test_suite: GdUnitTestSuite
  func _init(create_task_test_suite: GdUnitTestSuite) -> void:
    test_suite = create_task_test_suite

  func create_task(task_name: String, parent_name: String, optional: bool, difficulty: int) -> void:
    test_suite.task_name_text_edit.text = task_name
    test_suite.task_parent_option_button.select(find_index_in_option_button(test_suite.task_parent_option_button, parent_name))
    test_suite.task_optional_check_button.set_pressed_no_signal(optional)
    test_suite.task_difficulty_option_button.select(test_suite.task_difficulty_option_button.get_item_index(difficulty as int))
    test_suite.add_task_dialog._on_add_task_pressed()
  
  func find_index_in_option_button(option_button: OptionButton, text: String) -> int:
    for i: int in option_button.get_child_count():
      if option_button.get_item_text(i) == text:
        return i
    return -1

const MainGameSceneRes = preload("res://scenes/MainGameScene.tscn")
const MainGameScene = preload("res://scripts/main_game_scene.gd")
var add_task_dialog: AddTaskDialog
var task_name_text_edit: TextEdit
var task_parent_option_button: OptionButton
var task_optional_check_button: CheckButton
var task_difficulty_option_button: OptionButton
var add_task_button: Button
var runner
var utils: Utils

func before() -> void:
  print("Starting Create Task testsuite")
  runner = scene_runner(auto_free(MainGameSceneRes.instantiate()))
  add_task_dialog = runner.invoke("get_node", "AddTaskDialog") as AddTaskDialog
  task_name_text_edit = add_task_dialog.get_node("TaskName")
  task_parent_option_button = add_task_dialog.get_node("Parent")
  task_optional_check_button = add_task_dialog.get_node("Optional")
  task_difficulty_option_button = add_task_dialog.get_node("Difficulty")
  add_task_button = add_task_dialog.get_node("AddTask")
  utils = Utils.new(self)
  
func test_task_create() -> void:
  utils.create_task("TaskName", "", false, Difficulty.Easy)
  var task: Task = Task.new("TaskName", null, false, Difficulty.Easy)
  var control_tasks := [task]
  var tasks_in_task_bank = runner.scene().task_bank.get_tasks()
  var enemies: Dictionary = runner.scene().game_world.enemies
  var monsters: Array[GameWorld.Enemy]
  for monster_position: Vector2i in enemies:
    monsters.append(enemies[monster_position])
  var control_monsters: Array[GameWorld.Enemy]
  control_monsters.append(GameWorld.Enemy.new(task))
  assert_array(tasks_in_task_bank)\
    .has_size(1)\
    .contains(control_tasks)
  assert_array(monsters)\
    .has_size(1)\
    .contains(control_monsters)
  
func delete_everything_before_the_last_occurence_of_test_in_this_name_to_make_it_a_test_learning() -> void:
  var check := false
  param(check)
  assert_bool(check).is_true()

func param(check: bool) -> void:
  check = not check

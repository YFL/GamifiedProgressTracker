extends GdUnitTestSuite

class Utils extends RefCounted:
  var test_suite: GdUnitTestSuite
  func _init(create_task_test_suite: GdUnitTestSuite) -> void:
    test_suite = create_task_test_suite

  func create_task(task_name: String, parent_name: String, optional: bool, difficulty: Task.TaskDifficulty) -> void:
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
var tasks: VBoxContainer
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
  var tasks_control = runner.invoke("get_node", "Tasks") as Tasks
  tasks = tasks_control.get_node("TasksVBox")
  utils = Utils.new(self)
  
func test_task_create() -> void:
  utils.create_task("TaskName", "", false, Task.TaskDifficulty.Easy)
  var task: Task = Task.new("TaskName", null, false, Task.TaskDifficulty.Easy)
  var control_tasks := [task]
  var control_string := task.name
  var control_strings := [control_string]
  var scene_tasks = runner.scene().tasks.get_tasks()
  var tasks: Array[String]
  for task_list_item: TaskListItem in self.tasks.get_children():
    tasks.append(task_list_item.task_name.text)
  assert_array(scene_tasks)\
    .has_size(1)\
    .contains(control_tasks)
  assert_array(tasks)\
    .has_size(1)\
    .contains(control_strings)
  
func delete_everything_before_the_last_occurence_of_test_in_this_name_to_make_it_a_test_learning() -> void:
  var option_button = auto_free(OptionButton.new())
  option_button.add_item("a")
  option_button.add_item("a")
  assert_int(option_button.get_item_count()).is_equal(1)

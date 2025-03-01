extends GdUnitTestSuite

class Utils extends RefCounted:
  var test_suite: GdUnitTestSuite
  func _init(create_task_test_suite: GdUnitTestSuite) -> void:
    test_suite = create_task_test_suite

  func create_task(task_name: String, description: String, parent_name: String, difficulty: int) -> void:
    test_suite.task_name_text_edit.text = task_name
    test_suite.task_description_text_edit.text = description
    test_suite.task_parent_option_button.select(find_index_in_option_button(test_suite.task_parent_option_button, parent_name))
    test_suite.task_difficulty_option_button.select(test_suite.task_difficulty_option_button.get_item_index(difficulty as int))
    test_suite.add_task_dialog._on_add_task_pressed()
  
  func find_index_in_option_button(option_button: OptionButton, text: String) -> int:
    for i: int in option_button.get_child_count():
      if option_button.get_item_text(i) == text:
        return i
    return -1

const MainGameSceneRes = preload("res://scenes/MainGameScene.tscn")
var add_task_dialog: AddTaskDialog
var task_name_text_edit: TextEdit
var task_description_text_edit: TextEdit
var task_parent_option_button: OptionButton
var task_difficulty_option_button: OptionButton
var add_task_button: Button
var runner
var utils: Utils

func before() -> void:
  print("Starting Create Task testsuite")
  runner = scene_runner(auto_free(MainGameSceneRes.instantiate()))
  add_task_dialog = runner.invoke("get_node", "AddTaskDialog") as AddTaskDialog
  task_name_text_edit = add_task_dialog.get_node("GridContainer").get_node("TaskName")
  task_description_text_edit = add_task_dialog.get_node("GridContainer").get_node("Description")
  task_parent_option_button = add_task_dialog.get_node("GridContainer").get_node("Parent")
  task_difficulty_option_button = add_task_dialog.get_node("GridContainer").get_node("Difficulty")
  add_task_button = add_task_dialog.get_node("GridContainer").get_node("AddTask")
  utils = Utils.new(self)
  
func test_task_create() -> void:
  utils.create_task("TaskName", "Description", "", Difficulty.NoteWorthy)
  var task: Task = Task.new("TaskName", "Description", null, Difficulty.NoteWorthy)
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

func test_add_bigger_child_task_than_free_capacity() -> void:
  var project := Project.new("ProjectName", "ProjectDescription", null, Difficulty.NoteWorthy)
  var child_project := Project.new("Project2", "Description2", project, Difficulty.NoteWorthy)
  var project_child := Task.new("Task1", "TaskDescription", project, Difficulty.NoteWorthy)
  assert_array(project.children).has_size(2).contains([child_project, project_child])
  var child_project_child :=\
    Task.new("Task2", "Shouldn't get added", child_project, Difficulty.Modest)
  assert_array(child_project.children).has_size(0).not_contains([child_project_child])
  var child_project_child_project :=\
    Project.new("Project3", "Description3", child_project, Difficulty.NoteWorthy)
  var child_project_child_project_child :=\
    Task.new("Task3", "TaskDescription3", child_project_child_project, Difficulty.Modest)
  assert_array(child_project_child_project.children)\
    .has_size(0)\
    .not_contains([child_project_child_project_child])

  
func delete_everything_before_the_last_occurence_of_test_in_this_name_to_make_it_a_test_learning() -> void:
  var check := false
  param(check)
  assert_bool(check).is_true()

func param(check: bool) -> void:
  check = not check

extends Node2D

const tasks_key := "tasks"
const rewards_key := "rewards"
const projects_key := "projects"

const invalid_save_file_msg := "Invalid save file: "

## Main task_bank, that when completed (optionality is taken into account), the
## project is finished.
var task_bank := TaskBank.new()
var reward_bank := RewardBank.new() 
var project_bank := ProjectBank.new()

var exe_dir := OS.get_executable_path().get_base_dir()

@onready var game_world: GameWorld = $GameWorld
@onready var add_task_dialog: AddTaskDialog = $AddTaskDialog
@onready var add_reward_dialog: AddRewardDialog = $AddRewardDialog
@onready var add_project_dialog: AddProjectDialog = $AddProjectDialog
@onready var popup_screen_container: CenterContainer = $PopupScreenContainer
@onready var button_panel: ButtonPanel = $ButtonsPanel
@onready var reward_screen: RewardScreen = preload("res://scenes/RewardScreen.tscn").instantiate()
@onready var error_screen: ErrorScreen = preload("res://scenes/ErrorScreen.tscn").instantiate()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
  project_bank.project_added.connect(add_task_dialog._on_project_added)
  project_bank.project_removed.connect(add_task_dialog._on_project_removed)
  project_bank.project_added.connect(add_project_dialog._on_project_added)
  project_bank.project_removed.connect(add_project_dialog._on_project_removed)
  popup_screen_container.add_child(reward_screen)
  popup_screen_container.add_child(error_screen)
  reward_screen.hide()
  error_screen.hide()

func _unhandled_input(event: InputEvent) -> void:
  if event is InputEventMouseMotion:
    print(get_local_mouse_position())
    if get_local_mouse_position() <= Vector2(5.0, 5.0):
      button_panel.slide_in()
    else:
      button_panel.slide_out()

func _on_add_task(name: String, description: String, parent_name: String, optional: bool, difficulty: int) -> void:
  var cant_add_task_text = "Can't add task: "
  if parent_name != "" and not project_bank.has(parent_name):
    show_error_screen(cant_add_task_text + "No parent exists with the given name.")
    return
  var parent := project_bank.get_project(parent_name)
  if parent != null and not parent.can_fit(difficulty):
    show_error_screen(cant_add_task_text + "Parent doesn't have enough free capacity for the task.")
    return
  var task := task_bank.create(name, description, parent, optional, difficulty)
  if task == null:
    show_error_screen(cant_add_task_text + "A task with the same name already extists.")
    return
  task.done.connect(_on_task_done)
  # If the return value from the find here is null, something is seriously messed up.
  GameWorld.find_game_world_for_taskoid(task, game_world).add_monster(task)

func _on_add_reward(name: String, difficulty: int, tier: Reward.RewardTier) -> void:
  if reward_bank.create(name, difficulty, tier) == null:
    show_error_screen("Can't add reward: A reward with the same name already exists.")
    return

func _on_add_project(name: String, description: String, parent: String, duration: int) -> void:
  print("HUUUUUU")
  var cant_add_project_text = "Can't add project: "
  if not parent.is_empty() and not project_bank.has(parent):
    show_error_screen(cant_add_project_text + "No parent exists with the given name.")
    return
  var parent_project := project_bank.get_project(parent)
  if parent_project != null and not parent_project.can_fit(duration):
    show_error_screen(cant_add_project_text +\
      "Project capacity is bigger then it's parent's free capacity.")
    return
  var project := project_bank.create(name, description, parent_project, duration)
  if project == null:
    show_error_screen(cant_add_project_text + "A project with the same name already exists.")
    return
  var result :=\
    GameWorld.new_game_world(project, GameWorld.find_game_world_for_taskoid(project, game_world))
  if not result.result:
    show_error_screen(cant_add_project_text + result.error)
    return

func _on_task_done(task: Task) -> void:
  var reward := reward_bank.reward_for(task.difficulty)
  if reward == null:
    return
  reward_screen.reward.text = reward.name
  reward_screen.show()

func _on_add_task_pressed() -> void:
  add_task_dialog.visible = not add_task_dialog.visible

func _on_add_reward_pressed() -> void:
  add_reward_dialog.visible = not add_reward_dialog.visible

func _on_add_project_pressed() -> void:
  add_project_dialog.visible = not add_project_dialog.visible

func show_error_screen(error: String) -> void:
  error_screen.text.text = error
  error_screen.show()

func _on_save_button_pressed() -> void:
  var save_dialog := CustomFileDialog.new(FileDialog.FILE_MODE_SAVE_FILE)
  add_child(save_dialog)
  save_dialog.show()
  await save_dialog.finished
  if save_dialog.valid:
    var file := FileAccess.open(save_dialog.current_file, FileAccess.WRITE)
    var to_store := {}
    to_store[tasks_key] = task_bank.to_dict()
    to_store[projects_key] = project_bank.to_dict()
    to_store[rewards_key] = reward_bank.to_dict()
    file.store_string(JSON.stringify(to_store))
  remove_child(save_dialog)
  save_dialog.queue_free()

func _on_load_button_pressed() -> void:
  var load_dialog := CustomFileDialog.new(FileDialog.FILE_MODE_OPEN_FILE)
  add_child(load_dialog)
  load_dialog.show()
  await load_dialog.finished
  if load_dialog.valid:
    if not FileAccess.file_exists(load_dialog.current_file):
      # This might not ever be the case though...
      show_error_screen("File doesn't exist")
    else:
      reset()
      load_saved_state(load_dialog.current_file)  
  remove_child(load_dialog)
  load_dialog.queue_free()

func load_saved_state(path: String) -> void:
  var save_file := FileAccess.open(path, FileAccess.READ)
  var jsonParser = JSON.new()
  if jsonParser.parse(save_file.get_as_text()) != OK:
    show_error_screen(invalid_save_file_msg + "couldn't parse contents as JSON")
    reset()
    return
  var dict = jsonParser.data
  if typeof(dict) != TYPE_DICTIONARY:
    show_error_screen(invalid_save_file_msg + "root element is not a dictionary")
    reset()
    return
  load_projects(dict)
  load_tasks(dict)
  load_rewards(dict)
  

# dict contains project names as keys and dictionaries as values, each of which represents a project
func load_project_tree(dict: Dictionary, project_name: String) -> bool:
  var project_dict = dict.get(project_name, null)
  if project_dict == null:
    handle_project_loading_error(project_name,
      "project with the given name doesn't exist in the save")
    return false
  if typeof(project_dict) != TYPE_DICTIONARY:
    handle_project_loading_error(project_name, "is not a dictionary")
    return false
  var parent_name = project_dict.get(Project.parent_name_key, null)
  if typeof(parent_name) != TYPE_STRING:
    handle_project_loading_error(project_name, "parent name is not a string: " + str(parent_name))
    return false
  if not parent_name.is_empty():
    if not load_project_tree(dict, parent_name):
      return false
  var project_name_field_value = project_dict.get(Project.name_key, null)
  if project_name_field_value == null:
    handle_project_loading_error(project_name, "no name in project")
    return false
  if typeof(project_name_field_value) != TYPE_STRING:
    handle_project_loading_error(project_name, "name field value is not a string")
    return false
  if project_name_field_value != project_name:
    handle_project_loading_error(project_name,
      "project name key \"" + project_name + "\" doesn't equal project name field value \"" +
      project_name_field_value + "\".")
    return false
  if not project_bank.has(project_name_field_value):
    var project_description = project_dict.get(Project.description_key, null)
    if project_description == null:
      show_project_loading_error(project_name,
        "project description missing. Empty string will be used")
      project_description = ""
    if typeof(project_description) != TYPE_STRING:
      handle_project_loading_error(project_name, "project description is not a string")
      return false
    var project_capacity = project_dict.get(Project.capacity_key, null)
    if project_capacity == null:
      handle_project_loading_error(project_name, "project capacity missing")
      return false
    if typeof(project_capacity) != TYPE_FLOAT:
      handle_project_loading_error(project_name, "project capacity is not a number")
      return false
    _on_add_project(
      project_name_field_value,
      project_description,
      parent_name,
      project_capacity)
  return true

func load_projects(saveDict: Dictionary) -> void:
  var projects = saveDict.get(projects_key, null)
  if projects == null:
    show_error_screen(invalid_save_file_msg + "projects key missing")
    reset()
    return
  if typeof(projects) != TYPE_DICTIONARY:
    show_error_screen(invalid_save_file_msg + "projects is not a dictionary")
    reset()
    return
  for project_name in saveDict[projects_key].keys():
    if not load_project_tree(projects, project_name):
      return

func load_tasks(saveDict: Dictionary) -> void:
  var tasks = saveDict.get(tasks_key, null)
  if tasks == null:
    show_error_screen(invalid_save_file_msg + "tasks key missing")
    reset()
    return
  if typeof(tasks) != TYPE_DICTIONARY:
    show_error_screen(invalid_save_file_msg + "tasks is not a dictionary")
    reset()
    return
  for task_name in tasks.keys():
    var task = tasks.get(task_name, null)
    if typeof(task) != TYPE_DICTIONARY:
      handle_task_loading_error(task_name, "task is not a dictionary")
      return
    var task_name_field_value = task.get(Task.name_key, null)
    if task_name_field_value == null:
      handle_task_loading_error(task_name, "task name is missing")
      return
    if typeof(task_name_field_value) != TYPE_STRING:
      handle_task_loading_error(task_name, "task name is not a string")
      return
    if task_name_field_value != task_name:
      handle_task_loading_error(task_name,
        "task name key \"" + task_name + "\" doesn't equal reward name field value \"" +
        task_name_field_value + "\".")
      return
    var task_description = task.get(Task.description_key, null)
    if task_description == null:
      show_task_loading_error(task_name, "task description is missing. Empty string will be used.")
      task_description = ""
    if typeof(task_description) != TYPE_STRING:
      handle_task_loading_error(task_name, "task description is not a string")
      return
    var task_parent_name = task.get(Task.parent_name_key, null)
    if task_parent_name == null:
      handle_task_loading_error(task_name, "task parent name is missing")
      return
    if typeof(task_parent_name) != TYPE_STRING:
      handle_task_loading_error(task_name, "task parent name is not a string")
      return
    var task_optional = task.get(Task.optional_key, null)
    if task_optional == null:
      handle_task_loading_error(task_name, "optional is missing")
      return
    if typeof(task_optional) != TYPE_BOOL:
      handle_task_loading_error(task_name, "optional is not a bool")
      return
    var task_difficulty = task.get(Task.difficulty_key, null)
    if task_difficulty == null:
      handle_task_loading_error(task_name, "task difficulty missing")
      return
    if typeof(task_difficulty) != TYPE_FLOAT:
      handle_task_loading_error(task_name, "task difficulty is not a number")
      return
    var task_completed = task.get(Task.completed_key, null)
    if task_completed == null:
      handle_task_loading_error(task_name, "completed is missing")
      return
    if typeof(task_completed) != TYPE_BOOL:
      handle_task_loading_error(task_name, "completed is not a bool")
      return
    _on_add_task(
      task_name,
      task_description,
      task_parent_name,
      task_optional,
      task_difficulty)
    if task_completed:
      task_bank.get_task(task_name).complete()

func load_rewards(dict: Dictionary) -> void:
  var rewards = dict.get(rewards_key, null)
  if typeof(rewards) != TYPE_DICTIONARY:
    show_error_screen(invalid_save_file_msg + "missing rewards key")
    reset()
    return
  for reward_name in rewards.keys():
    var reward = rewards.get(reward_name, null)
    if typeof(reward) != TYPE_DICTIONARY:
      handle_reward_loading_error(reward_name, "reward is not a dictionary")
      return
    var reward_name_field_value = reward.get(Reward.name_key, null)
    if reward_name_field_value == null:
      handle_reward_loading_error(reward_name, "reward name is missing")
      return
    if typeof(reward_name_field_value) != TYPE_STRING:
      handle_reward_loading_error(reward_name, "reward name is not a string")
      return
    if reward_name_field_value != reward_name:
      handle_reward_loading_error(reward_name,
        "reward name key \"" + reward_name + "\" doesn't equal reward name field value \"" +
        reward_name_field_value + "\".")
      return
    var reward_difficulty = reward.get(Reward.difficulty_key, null)
    if reward_difficulty == null:
      handle_reward_loading_error(reward_name, "reward difficulty is missing")
      return
    if typeof(reward_difficulty) != TYPE_FLOAT:
      handle_reward_loading_error(reward_name, "reward difficulty is not a number")
      return
    var reward_tier = reward.get(Reward.tier_key, null)
    if reward_tier == null:
      handle_reward_loading_error(reward_name, "reward tier is missing")
      return
    if typeof(reward_tier) != TYPE_FLOAT:
      handle_reward_loading_error(reward_name, "reward tier is not a number")
      return
    _on_add_reward(reward_name, reward_difficulty, reward_tier)

func reset() -> void:
  remove_child(game_world)
  game_world.queue_free()
  var result := GameWorld.new_game_world(null, null)
  if not result.error.is_empty():
    show_error_screen("Couldn't create new game world: "  + result.error)
  else:
    game_world = result.result
    add_child(game_world)
    move_child(game_world, 0)
    game_world.show()
  task_bank.reset()
  project_bank.reset()
  reward_bank.reset()

func show_project_loading_error(project_name: String, error_msg: String) -> void:
  show_error_screen(invalid_save_file_msg + "Problem loading project \"" + project_name + "\": " +
    error_msg)
  
func show_task_loading_error(task_name: String, error_msg: String) -> void:
  show_error_screen(invalid_save_file_msg + "Problem loading task \"" + task_name + "\": " +
    error_msg)

func show_reward_loading_error(reward_name: String, error_msg: String) -> void:
  show_error_screen(invalid_save_file_msg + "Problem loading reward \"" + reward_name + "\": " +
    error_msg)

func handle_project_loading_error(project_name: String, error_msg: String) -> void:
  show_project_loading_error(project_name, error_msg)
  reset()

func handle_task_loading_error(task_name: String, error_msg: String) -> void:
  show_task_loading_error(task_name, error_msg)
  reset()

func handle_reward_loading_error(reward_name: String, error_msg: String) -> void:
  show_reward_loading_error(reward_name, error_msg)
  reset()
extends Node2D

const tasks_key := "tasks"
const rewards_key := "rewards"
const projects_key := "projects"

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
@onready var reward_screen: RewardScreen = preload("res://scenes/RewardScreen.tscn").instantiate()
@onready var error_screen: ErrorScreen = preload("res://scenes/ErrorScreen.tscn").instantiate()
@onready var load_file_dialog := FileDialog.new()

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
  load_file_dialog.hide()
  load_file_dialog.access = FileDialog.ACCESS_FILESYSTEM
  load_file_dialog.file_mode = FileDialog.FILE_MODE_OPEN_FILE
  load_file_dialog.file_selected.connect(self._on_load_file_selected)
  add_child(load_file_dialog)

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
  # I don't think this is necessary really, or we should add it to the task function as well, for
  # the same reasons we would keep this here.
  # if project_bank.has(name):
  #   return
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
  add_task_dialog.reset()
  add_task_dialog.visible = not add_task_dialog.visible

func _on_add_reward_pressed() -> void:
  add_reward_dialog.reset()
  add_reward_dialog.visible = not add_reward_dialog.visible

func _on_add_project_pressed() -> void:
  add_project_dialog.reset()
  add_project_dialog.visible = not add_project_dialog.visible

func show_error_screen(error: String) -> void:
  error_screen.text.text = error
  error_screen.show()

func _on_save_button_pressed() -> void:
  print("Exe dir: " + exe_dir)
  var file := FileAccess.open(exe_dir + "/save.json", FileAccess.WRITE)
  var to_store := {}
  to_store[tasks_key] = task_bank.to_dict()
  to_store[projects_key] = project_bank.to_dict()
  to_store[rewards_key] = reward_bank.to_dict()
  file.store_string(JSON.stringify(to_store))

func _on_load_button_pressed() -> void:
  var file_path := exe_dir + "/save.json"
  if not FileAccess.file_exists(file_path):
    load_file_dialog.show()
  else:
    load_saved_state(file_path)

func _on_load_file_selected(path: String) -> void:
  load_file_dialog.hide()
  load_saved_state(path)

func load_saved_state(path: String) -> void:
  var save_file := FileAccess.open(path, FileAccess.READ)
  var dict: Dictionary = JSON.parse_string(save_file.get_as_text())
  var projects: Dictionary = dict[projects_key]
  for project_name in dict[projects_key].keys():
    load_project_tree(projects, project_name)
  var tasks: Dictionary = dict[tasks_key]
  for task_name in tasks.keys():
    var task: Dictionary = tasks[task_name]
    _on_add_task(
      task_name,
      task[Task.description_key],
      task[Task.parent_name_key],
      task[Task.optional_key],
      task[Task.difficulty_key])
    if task[Task.completed_key]:
      task_bank.get_task(task_name).complete()
  var rewards: Dictionary = dict[rewards_key]
  for reward_name in rewards.keys():
    var reward: Dictionary = rewards[reward_name]
    _on_add_reward(reward_name, reward[Reward.difficulty_key], reward[Reward.tier_key])

# dict contains project names as keys and dictionaries as values, each of which represents a project
func load_project_tree(dict: Dictionary, project_name: String) -> void:
  var parent_project: Project = null
  var project_dict: Dictionary = dict[project_name]
  var parent_name: String = project_dict[Project.parent_name_key]
  if not parent_name.is_empty():
    load_project_tree(dict, parent_name)
    parent_project = project_bank.get_project(parent_name)
  if not project_bank.has(project_dict[Project.name_key]):
    _on_add_project(
      project_dict[Project.name_key],
      project_dict[Project.description_key],
      parent_name,
      project_dict[Project.capacity_key])

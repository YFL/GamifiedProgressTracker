class_name MainGameScene extends Node2D

const tasks_key := "tasks"
const rewards_key := "rewards"
const projects_key := "projects"

const invalid_save_file_msg := "Invalid save file: "

const GameWorldScene := preload("res://scenes/GameWorld.tscn")

var taskoid_bank := TaskoidBank.new()
var reward_bank := RewardBank.new()
var game_world: GameWorld = GameWorldScene.instantiate()

@onready var game_world_display: GameWorldDisplay = $SubViewportContainer/GameWorldViewport/GameWorldDisplay
@onready var add_task_dialog: AddTaskDialog = $AddTaskDialog
@onready var add_reward_dialog: AddRewardDialog = $AddRewardDialog
@onready var add_project_dialog: AddProjectDialog = $AddProjectDialog
@onready var popup_screen_container: CenterContainer = $PopupScreenContainer
@onready var button_panel: ButtonPanel = $ButtonsPanel
@onready var reward_screen: RewardScreen = preload("res://scenes/RewardScreen.tscn").instantiate()
@onready var taskoid_tree: TreeScreen = preload("res://scenes/TreeScreen.tscn").instantiate()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
  taskoid_bank.project_added.connect(add_task_dialog._on_project_added)
  taskoid_bank.project_removed.connect(add_task_dialog._on_project_removed)
  taskoid_bank.project_added.connect(add_project_dialog._on_project_added)
  taskoid_bank.project_removed.connect(add_project_dialog._on_project_removed)
  taskoid_bank.project_added.connect(taskoid_tree.add_taskoid)
  taskoid_bank.task_added.connect(taskoid_tree.add_taskoid)
  popup_screen_container.add_child(reward_screen)
  popup_screen_container.add_child(Globals.error_screen)
  taskoid_tree.name = "TaskoidTree"
  add_child(taskoid_tree)
  taskoid_tree.position = Vector2(button_panel.size.x + 10, 0)
  await get_tree().process_frame
  reward_screen.hide()
  taskoid_tree.hide()
  Globals.error_screen.hide()
  game_world_display.set_game_world(game_world)
  game_world.open_game_world.connect(game_world_display.set_game_world)

func _unhandled_input(event: InputEvent) -> void:
  if event is InputEventMouseMotion:
    if get_local_mouse_position() <= Vector2(5.0, 5.0):
      button_panel.slide_in()
    else:
      button_panel.slide_out()

func _on_add_task(config: Taskoid.Config, position = Vector2i(-1, -1)) -> void:
  var cant_add_task_text = "Can't add task: "
  var result := taskoid_bank.create_task(config)
  var task: Task = result.result
  if result.result == null:
    Globals.show_error_screen(cant_add_task_text + result.error)
    return
  task.done.connect(_on_task_done)
  # If the return value from the find here is null, something is seriously messed up.
  GameWorld.find_game_world_for_taskoid(task, game_world).add_monster(task, position)

func _on_add_reward(name: String, difficulty: int, tier: Reward.RewardTier) -> void:
  if reward_bank.create(name, difficulty, tier) == null:
    Globals.show_error_screen("Can't add reward: A reward with the same name already exists.")
    return

func _on_add_project(config: Taskoid.Config, position = Vector2i(-1, -1)) -> void:
  var cant_add_project_text = "Can't add project: "
  var result := taskoid_bank.create_project(config)
  var project: Project = result.result
  if project == null:
    Globals.show_error_screen(cant_add_project_text + result.error)
    return
  var game_world_for_taskoid := GameWorld.find_game_world_for_taskoid(project, game_world)
  result =\
    GameWorld.new_game_world(project, game_world_for_taskoid, position)
  if not result.result:
    Globals.show_error_screen(cant_add_project_text + result.error)
    return
  project.done.connect(_on_task_done)
  project.done.connect(game_world_for_taskoid._on_project_done)
  var gw := result.result as GameWorld
  if gw.open_game_world.connect(game_world_display.set_game_world) != 0:
    Globals.show_error_screen("Couldn't connect open_game_world to game_world_display.set_game_world")

func _on_task_done(task: Taskoid) -> void:
  var difficulty: int
  if task is Task:
    difficulty = (task as Task).difficulty
  else:
    difficulty = (task as Project).difficulty
  var reward := reward_bank.reward_for(difficulty)
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

func _on_save_button_pressed() -> void:
  var save_dialog := CustomFileDialog.new(FileDialog.FILE_MODE_SAVE_FILE)
  add_child(save_dialog)
  save_dialog.show()
  await save_dialog.finished
  if save_dialog.valid:
    var file := FileAccess.open(save_dialog.current_file, FileAccess.WRITE)
    var to_store: Dictionary = game_world.to_dict()
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
      Globals.show_error_screen("File doesn't exist")
    else:
      reset()
      load_saved_state(load_dialog.current_file)  
  remove_child(load_dialog)
  load_dialog.queue_free()

func load_saved_state(path: String) -> void:
  var save_file := FileAccess.open(path, FileAccess.READ)
  var jsonParser = JSON.new()
  if jsonParser.parse(save_file.get_as_text()) != OK:
    Globals.show_error_screen(invalid_save_file_msg + "couldn't parse contents as JSON")
    reset()
    return
  var dict = jsonParser.data
  if typeof(dict) != TYPE_DICTIONARY:
    Globals.show_error_screen(invalid_save_file_msg + "root element is not a dictionary")
    reset()
    return
  load_projects(dict)
  load_tasks(dict)
  load_rewards(dict)
  

# dict contains project names as keys and dictionaries as values, each of which represents a project
## Loads the tree ABOVE the current project, i.e. only the parents, not the children.
func load_project_tree(dict: Dictionary, project_name: String) -> bool:
  var project_dict = dict.get(project_name)
  if project_dict == null:
    handle_project_loading_error(project_name,
      "project with the given name doesn't exist in the save")
    return false
  if typeof(project_dict) != TYPE_DICTIONARY:
    handle_project_loading_error(project_name, "is not a dictionary")
    return false
  var res := Taskoid.config_from_dict(project_dict)
  if res.result == null:
    handle_project_loading_error(project_name, res.error)
    return false
  var config: Taskoid.Config = res.result
  if not config.parent.is_empty():
    if not taskoid_bank.has_project_name(config.parent):
      if not load_project_tree(dict, config.parent):
        return false
  res = load_position_from_dict(project_dict)
  if res.result == null:
    handle_project_loading_error(project_name, res.error)
    return false
  var project_position: Vector2i = res.result
  _on_add_project(config, project_position)
  if config.completed:
    taskoid_bank.get_project(config.name).complete()
  return true

func load_projects(saveDict: Dictionary) -> void:
  var projects = saveDict.get(projects_key)
  if projects == null:
    Globals.show_error_screen(invalid_save_file_msg + "projects key missing")
    reset()
    return
  if typeof(projects) != TYPE_DICTIONARY:
    Globals.show_error_screen(invalid_save_file_msg + "projects is not a dictionary")
    reset()
    return
  for project_name in saveDict[projects_key].keys():
    # Trying to load a project, that already exists would result in an errror being shown.
    if taskoid_bank.has_project_name(project_name):
      continue
    if not load_project_tree(projects, project_name):
      return

func load_tasks(saveDict: Dictionary) -> void:
  var tasks = saveDict.get(tasks_key)
  if tasks == null:
    Globals.show_error_screen(invalid_save_file_msg + "tasks key missing")
    reset()
    return
  if typeof(tasks) != TYPE_DICTIONARY:
    Globals.show_error_screen(invalid_save_file_msg + "tasks is not a dictionary")
    reset()
    return
  for task_name in tasks.keys():
    var task = tasks.get(task_name)
    if typeof(task) != TYPE_DICTIONARY:
      handle_task_loading_error(task_name, "task is not a dictionary")
      return
    var res := Taskoid.config_from_dict(task)
    if res.result == null:
      handle_task_loading_error(task_name, res.error)
      return
    var config: Taskoid.Config = res.result
    res = load_position_from_dict(task)
    if res.result == null:
      handle_task_loading_error(task_name, res.error)
      return
    var task_position: Vector2i = res.result
    _on_add_task(config, task_position)
    if config.completed:
      taskoid_bank.get_task(task_name).complete()

func load_rewards(dict: Dictionary) -> void:
  var rewards = dict.get(rewards_key)
  if typeof(rewards) != TYPE_DICTIONARY:
    Globals.show_error_screen(invalid_save_file_msg + "missing rewards key")
    reset()
    return
  for reward_name in rewards.keys():
    var reward = rewards.get(reward_name)
    if typeof(reward) != TYPE_DICTIONARY:
      handle_reward_loading_error(reward_name, "reward is not a dictionary")
      return
    var reward_name_field_value = reward.get(Reward.name_key)
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
    var reward_difficulty = reward.get(Reward.difficulty_key)
    if reward_difficulty == null:
      handle_reward_loading_error(reward_name, "reward difficulty is missing")
      return
    if typeof(reward_difficulty) != TYPE_FLOAT:
      handle_reward_loading_error(reward_name, "reward difficulty is not a number")
      return
    var reward_tier = reward.get(Reward.tier_key)
    if reward_tier == null:
      handle_reward_loading_error(reward_name, "reward tier is missing")
      return
    if typeof(reward_tier) != TYPE_FLOAT:
      handle_reward_loading_error(reward_name, "reward tier is not a number")
      return
    _on_add_reward(reward_name, reward_difficulty, reward_tier)

func load_position_from_dict(dict: Dictionary) -> Result:
  var position = dict.get(GameWorld.position_key)
  if position == null:
    return Result.Error("Position is missing")
  position = str_to_var("Vector2i" + position)
  if typeof(position) != TYPE_VECTOR2I:
    return Result.Error("Position is not a vector2i")
  return Result.new(position)

func reset() -> void:
  game_world.queue_free()
  var result := GameWorld.new_game_world(null, null)
  if not result.error.is_empty():
    Globals.show_error_screen("Couldn't create new game world: "  + result.error)
  else:
    game_world = result.result
    game_world_display.set_game_world(game_world)
    game_world.open_game_world.connect(game_world_display.set_game_world)
    game_world.show()
  taskoid_bank.reset()
  reward_bank.reset()
  add_project_dialog.clear()
  add_task_dialog.clear()

func show_project_loading_error(project_name: String, error_msg: String) -> void:
  Globals.show_error_screen(invalid_save_file_msg + "Problem loading project \"" + project_name + "\": " +
    error_msg)
  
func show_task_loading_error(task_name: String, error_msg: String) -> void:
  Globals.show_error_screen(invalid_save_file_msg + "Problem loading task \"" + task_name + "\": " +
    error_msg)

func show_reward_loading_error(reward_name: String, error_msg: String) -> void:
  Globals.show_error_screen(invalid_save_file_msg + "Problem loading reward \"" + reward_name + "\": " +
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

func _on_tree_button_pressed() -> void:
  taskoid_tree.visible = not taskoid_tree.visible

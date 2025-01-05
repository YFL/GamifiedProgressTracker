extends Node2D

## Main task_bank, that when completed (optionality is taken into account), the
## project is finished.
var task_bank := TaskBank.new()
var reward_bank := RewardBank.new() 
var project_bank := ProjectBank.new()

@onready var game_world: GameWorld = $GameWorld
@onready var add_task_dialog: AddTaskDialog = $AddTaskDialog
@onready var add_reward_dialog: AddRewardDialog = $AddRewardDialog
@onready var add_project_dialog: AddProjectDialog = $AddProjectDialog
@onready var popup_screen_container: CenterContainer = $PopupScreenContainer
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
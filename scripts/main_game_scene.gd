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
@onready var reward_screen_container: CenterContainer = $RewardScreenContainer
@onready var reward_screen: RewardScreen = preload("res://scenes/RewardScreen.tscn").instantiate()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
  project_bank.project_added.connect(add_task_dialog._on_project_added)
  project_bank.project_removed.connect(add_task_dialog._on_project_removed)
  project_bank.project_added.connect(add_project_dialog._on_project_added)
  project_bank.project_removed.connect(add_project_dialog._on_project_removed)
  task_bank.task_added.connect(game_world.add_monster)
  task_bank.task_removed.connect(game_world.remove_monster)
  reward_screen_container.add_child(reward_screen)
  reward_screen.hide()

func _on_add_task(name: String, parent_name: String, optional: bool, difficulty: int) -> void:
  if parent_name != "" and not project_bank.has(parent_name):
    return
  var parent := project_bank.get_project(parent_name)
  if parent != null and not parent.can_fit(difficulty):
    return
  var task := task_bank.create(name, parent, optional, difficulty)
  if task == null:
    # Todo: print some fucking error
    return
  task.done.connect(_on_task_done)

func _on_add_reward(name: String, difficulty: int, tier: Reward.RewardTier) -> void:
  reward_bank.create(name, difficulty, tier)

func _on_add_project(name: String, parent: String, duration: int) -> void:
  if project_bank.has(name):
    return
  if not parent.is_empty() and not project_bank.has(parent):
    return
  var parent_project := project_bank.get_project(parent)
  if parent_project != null and not parent_project.can_fit(duration):
    return
  project_bank.create(name, parent_project, duration)

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

extends Node2D

## Main task_bank, that when completed (optionality is taken into account), the
## project is finished.
var task_bank := TaskBank.new()
var reward_bank := RewardBank.new() 

@onready var game_world: GameWorld = $GameWorld
@onready var add_task_dialog: AddTaskDialog = $AddTaskDialog
@onready var tasks: Tasks = $Tasks

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
  ($AddRewardDialog as AddRewardDialog).visible = false
  task_bank.task_added.connect(add_task_dialog._on_task_added)
  task_bank.task_removed.connect(add_task_dialog._on_task_removed)
  task_bank.task_added.connect(tasks._on_task_added)
  task_bank.task_removed.connect(tasks._on_task_removed)
  task_bank.task_added.connect(game_world.add_monster)
  task_bank.task_removed.connect(game_world.remove_monster)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
  pass

func _on_add_task(name: String, parent_name: String, optional: bool, difficulty: Task.TaskDifficulty) -> void:
  if parent_name != "" and not task_bank.has(parent_name):
    return
  var parent := task_bank.get_task(parent_name) if parent_name != "" else null
  var task := task_bank.create(name, parent, optional, difficulty)
  if task == null:
    # Todo: print some fucking error
    return
  task.done.connect(_on_task_done)

func _on_add_reward(name: String, difficulty: Task.TaskDifficulty, tier: Reward.RewardTier) -> void:
  reward_bank.create(name, difficulty, tier)

func _on_add_reward_pressed() -> void:
  var add_reward_dialog: AddRewardDialog = $AddRewardDialog
  add_reward_dialog.reset()
  add_reward_dialog.visible = not add_reward_dialog.visible

func _on_task_done(task: Task) -> void:
  print(reward_bank.reward_for(task.own_difficulty))
extends Node2D

## Main tasks, that when completed (optionality is taken into account), the
## project is finished.
var tasks := TaskBank.new()
var rewards := RewardBank.new() 

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
  ($AddRewardDialog as AddRewardDialog).visible = false
  tasks.task_added.connect(($AddTaskDialog as AddTaskDialog)._on_task_added)
  tasks.task_removed.connect(($AddTaskDialog as AddTaskDialog)._on_task_removed)
  tasks.task_added.connect(($Tasks as Tasks)._on_task_added)
  tasks.task_removed.connect(($Tasks as Tasks)._on_task_removed)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
  pass

func _on_add_task(name: String, parent_name: String, optional: bool, difficulty: Task.TaskDifficulty) -> void:
  if parent_name != "" and not tasks.has(parent_name):
    return
  var parent := tasks.get_task(parent_name) if parent_name != "" else null
  var task := tasks.create(name, parent, optional, difficulty)
  if task == null:
    # Todo: print some fucking error
    return
  task.done.connect(_on_task_done)

func _on_add_reward(name: String, difficulty: Task.TaskDifficulty, tier: Reward.RewardTier) -> void:
  rewards.create(name, difficulty, tier)

func _on_add_reward_pressed() -> void:
  var add_reward_dialog: AddRewardDialog = $AddRewardDialog
  add_reward_dialog.reset()
  add_reward_dialog.visible = not add_reward_dialog.visible

func _on_task_done(task: Task) -> void:
  print(rewards.reward_for(task.own_difficulty))
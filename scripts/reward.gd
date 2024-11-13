class_name Reward extends RefCounted

enum RewardTier {
  Common,
  Rare,
  Epic,
  Legendary,
  Count
}

var name: String = ""
var difficulty: Task.TaskDifficulty = Task.TaskDifficulty.Easy
var tier: RewardTier = RewardTier.Common

func _init(name: String, difficulty: Task.TaskDifficulty, tier: RewardTier) -> void:
  self.name = name
  self.difficulty = difficulty
  self.tier = tier

func _to_string() -> String:
  return name + " " + Task.task_difficulty_names[difficulty] + " " + RewardTier.keys()[tier]

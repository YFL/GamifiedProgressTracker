class_name Reward extends RefCounted

enum RewardTier {
  Common,
  Rare,
  Epic,
  Legendary,
  Count
}

var name: String = ""
var difficulty := Difficulty.Easy
var tier: RewardTier = RewardTier.Common

func _init(name: String, difficulty: int, tier: RewardTier) -> void:
  self.name = name
  self.difficulty = difficulty
  self.tier = tier

func _to_string() -> String:
  return name + " " + Difficulty.difficulty_names[difficulty] + " " + RewardTier.keys()[tier]

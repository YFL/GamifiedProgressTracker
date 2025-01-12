class_name Reward extends RefCounted

enum RewardTier {
  Common,
  Rare,
  Epic,
  Legendary,
  Count
}

const name_key = "name"
const difficulty_key = "difficulty"
const tier_key = "tier"

var name: String = ""
var difficulty := Difficulty.Modest
var tier: RewardTier = RewardTier.Common

func _init(name: String, difficulty: int, tier: RewardTier) -> void:
  self.name = name
  self.difficulty = difficulty
  self.tier = tier

func _to_string() -> String:
  return name + " " + Difficulty.difficulty_names[difficulty] + " " + RewardTier.keys()[tier]

func to_dict() -> Dictionary:
  return {
    name_key: name,
    difficulty_key: difficulty,
    tier_key: tier
  }
class_name AddRewardDialog extends DialogBase

signal add_reward(name: String, difficulty: int, tier: Reward.RewardTier)

@onready var reward_name: TextEdit = $GridContainer/RewardName
@onready var difficulty_button: OptionButton = $GridContainer/DifficultyCategory
@onready var tier_button: OptionButton = $GridContainer/Tier

func name() -> String:
  return reward_name.text

func difficulty() -> int:
  return difficulty_button.get_item_id(difficulty_button.selected)

func tier() -> Reward.RewardTier:
  return tier_button.selected as Reward.RewardTier

func _on_add_reward_pressed() -> void:
  add_reward.emit(name(), difficulty(), tier())

func _reset() -> void:
  reward_name.clear()
  difficulty_button.select(0)
  tier_button.select(0)
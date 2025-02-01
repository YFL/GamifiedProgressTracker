class_name DifficultyOptionButton extends OptionButton

func _init() -> void:
  for difficulty: int in Difficulty.difficulty_names.keys():
    if difficulty == 0:
      continue
    add_item(Difficulty.difficulty_names[difficulty], difficulty)
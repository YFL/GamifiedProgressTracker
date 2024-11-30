class_name Difficulty extends Node

# The assigned values have days as unit
const Invalid := 0
const Easy := 1
const Medium := 10
const Hard := 20
const Gigantic := 60

static var difficulty_names: Dictionary = {
  Difficulty.Invalid: "Invalid",
  Difficulty.Easy: "Easy",
  Difficulty.Medium: "Medium",
  Difficulty.Hard: "Hard",
  Difficulty.Gigantic: "Gigantic"
}

static func string_to_difficulty(string: String) -> int:
  if string == "Easy":
    return Difficulty.Easy
  if string == "Medium":
    return Difficulty.Medium
  if string == "Hard":
    return Difficulty.Hard
  if string == "Gigantic":
    return Difficulty.Gigantic
  return Difficulty.Invalid

static func categorize_difficulty(combined_difficulty: int) -> int:
  match combined_difficulty:
    var new_diff when new_diff >= Difficulty.Gigantic:
      return Difficulty.Gigantic
    var new_diff when new_diff >= Difficulty.Hard:
      return Difficulty.Hard
    var new_diff when new_diff >= Difficulty.Medium:
      return Difficulty.Medium
    _:
      return Difficulty.Easy

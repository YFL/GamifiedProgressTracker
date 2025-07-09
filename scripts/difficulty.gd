class_name Difficulty extends Node

# The assigned values have minutes as unit
const Invalid := 0
const Modest := 10
const NoteWorthy := 6 * Modest
const Commendable := 8 * NoteWorthy
const Glorious := 3 * Commendable
const Heroic := 7 * Glorious
const Majestic := 4 * Heroic + 2 * Glorious
const Legendary := 12 * Majestic
const Imperial := 5 * Legendary
const Supreme := 4 * Imperial
const Transcendent := 4 * Supreme

static var difficulty_names: Dictionary = {
  Invalid: "Invalid",
  Modest: "Modest",
  NoteWorthy: "Noteworthy",
  Commendable: "Commendable",
  Glorious: "Glorious",
  Heroic: "Heroic",
  Majestic: "Majestic",
  Legendary: "Legendary",
  Imperial: "Imperial",
  Supreme: "Supreme",
  Transcendent: "Transcendent"
}

static func string_to_difficulty(string: String) -> int:
  if string == "Modest":
    return Modest
  if string == "Noteworthy":
    return NoteWorthy
  if string == "Commendable":
    return Commendable
  if string == "Glorious":
    return Glorious
  if string == "Heroic":
    return Heroic
  if string == "Majestic":
    return Majestic
  if string == "Legendary":
    return Legendary
  if string == "Imperial":
    return Imperial
  if string == "Supreme":
    return Supreme
  if string == "Transcendent":
    return Transcendent
  return Invalid

static func categorize_difficulty(combined_difficulty: int) -> int:
  match combined_difficulty:
    var new_diff when new_diff >= Transcendent:
      return Transcendent
    var new_diff when new_diff >= Supreme:
      return Supreme
    var new_diff when new_diff >= Imperial:
      return Imperial
    var new_diff when new_diff >= Legendary:
      return Legendary
    var new_diff when new_diff >= Majestic:
      return Majestic
    var new_diff when new_diff >= Heroic:
      return Heroic
    var new_diff when new_diff >= Glorious:
      return Glorious
    var new_diff when new_diff >= Commendable:
      return Commendable
    var new_diff when new_diff >= NoteWorthy:
      return NoteWorthy
    _:
      return Modest

static func highest_task_difficulty() -> int:
  return Heroic

static func lowest_project_difficulty() -> int:
  return Heroic

static func is_task_difficulty(difficulty: int) -> bool:
  return difficulty <= highest_task_difficulty()

static func is_project_difficulty(difficulty: int) -> bool:
  return difficulty >= lowest_project_difficulty()
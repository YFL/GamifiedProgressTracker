class_name Task extends RefCounted

signal done(task: Task)

# The assigned values have days as unit
enum TaskDifficulty {
  Invalid = 0,
  Easy = 1,
  Medium = 10,
  Hard = 20,
  Gigantic = 60
}

static var task_difficulty_names: Dictionary = {
  TaskDifficulty.Invalid: "Invalid",
  TaskDifficulty.Easy: "Easy",
  TaskDifficulty.Medium: "Medium",
  TaskDifficulty.Hard: "Hard",
  TaskDifficulty.Gigantic: "Gigantic"
}

static func string_to_task_difficulty(string: String) -> TaskDifficulty:
  if string == "Easy":
    return TaskDifficulty.Easy
  if string == "Medium":
    return TaskDifficulty.Medium
  if string == "Hard":
    return TaskDifficulty.Hard
  if string == "Gigantic":
    return TaskDifficulty.Gigantic
  return TaskDifficulty.Invalid

var name: String = ""
var completed: bool = false
var parent: Task = null
## Tells if the parent can be completed without completing this task.
var optional: bool = true
var children: Array[Task]
var combined_difficulty: TaskDifficulty = TaskDifficulty.Easy
var own_difficulty: TaskDifficulty = TaskDifficulty.Easy
var children_difficulty: int = 0

func _init(name: String, parent: Task, optional: bool, difficulty: TaskDifficulty) -> void:
  self.name = name
  self.parent = parent
  self.optional = optional
  own_difficulty = difficulty
  combined_difficulty = difficulty
  if parent:
    parent.add_child_task(self)

func _notification(what: int) -> void:
  if what == NOTIFICATION_PREDELETE:
    if parent:
      parent.remove_child_task(self)

func _to_string() -> String:
  return name + " Parent: " + (parent.name if parent != null else "None") + " Optional: " + str(optional) + " Difficulty: " + task_difficulty_names[combined_difficulty]

func add_child_task(child: Task) -> void:
  children.append(child)
  if child.optional:
    return
  children_difficulty += child.combined_difficulty
  combined_difficulty = categorize_difficulty(children_difficulty + own_difficulty)
  
func remove_child_task(child: Task) -> void:
  if children.find(child) >= 0:
    children.erase(child)
    if child.optional:
      return
    children_difficulty -= child.combined_difficulty
    combined_difficulty = categorize_difficulty(children_difficulty + own_difficulty)

func complete() -> bool:
  for child in children:
    if not child.completed and not child.optional:
      return false
  completed = true
  done.emit(self)
  return true

static func categorize_difficulty(combined_difficulty: int) -> TaskDifficulty:
  match combined_difficulty:
    var new_diff when new_diff >= TaskDifficulty.Gigantic:
      return TaskDifficulty.Gigantic
    var new_diff when new_diff >= TaskDifficulty.Hard:
      return TaskDifficulty.Hard
    var new_diff when new_diff >= TaskDifficulty.Medium:
      return TaskDifficulty.Medium
    _:
      return TaskDifficulty.Easy

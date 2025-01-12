class_name Task extends Taskoid

signal done(task: Task)

const completed_key = "completed"
const optional_key = "optional"
const difficulty_key = "difficulty"

var completed: bool = false
## Tells if the parent can be completed without completing this task.
var optional: bool = true
var difficulty: int = Difficulty.Modest

func _init(
  name: String,
  description: String,
  parent: Project,
  optional: bool,
  difficulty: int) -> void:
  super._init(name, description, parent)
  self.optional = optional
  self.difficulty = difficulty
  if parent:
    parent.add_task(self)

func _notification(what: int) -> void:
  if what == NOTIFICATION_PREDELETE:
    if parent:
      parent.remove_task(self)

func _to_string() -> String:
  return name + " Description: " + description + " Parent: "\
    + (parent.name if parent != null else "None") + " Optional: " + str(optional) + " Difficulty: "\
    + Difficulty.difficulty_names[difficulty]

func complete() -> void:
  completed = true
  done.emit(self)

func to_dict() -> Dictionary:
  var ret_val := super.to_dict()
  ret_val[completed_key] = completed
  ret_val[optional_key] = optional
  ret_val[difficulty_key] = difficulty
  return ret_val
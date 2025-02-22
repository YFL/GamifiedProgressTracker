class_name Task extends Taskoid

const difficulty_key = "difficulty"

## Tells if the parent can be completed without completing this task.
var difficulty: int = Difficulty.Modest

func _init(
  name: String,
  description: String,
  parent: Project,
  difficulty: int) -> void:
  super._init(name, description, parent)
  self.difficulty = difficulty
  if parent:
    parent.add_task(self)

func _notification(what: int) -> void:
  if what == NOTIFICATION_PREDELETE:
    if parent:
      parent.remove_task(self)

func _to_string() -> String:
  return name + " Description: " + description + " Parent: "\
    + (parent.name if parent != null else "None") + " Difficulty: "\
    + Difficulty.difficulty_names[difficulty]

func to_dict() -> Dictionary:
  var ret_val := super.to_dict()
  ret_val[difficulty_key] = difficulty
  return ret_val
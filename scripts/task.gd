class_name Task extends Taskoid

func _init(params: Taskoid.Params) -> void:
  super._init(params)
  self.difficulty = difficulty
  if parent:
    parent.add_task(self)

func _to_string() -> String:
  return name + " Description: " + description + " Parent: "\
    + (parent.name if parent != null else "None") + " Difficulty: "\
    + Difficulty.difficulty_names[difficulty]
class_name ProjectScreen extends TaskoidScreenBase

@onready var current_size: TextEdit = $Size

func set_taskoid(taskoid: Taskoid) -> void:
  if not taskoid is Project:
    return
  super.set_taskoid(taskoid)
  var project := taskoid as Project
  current_size.text =\
    Difficulty.difficulty_names[Difficulty.categorize_difficulty(project.children_difficulty)]
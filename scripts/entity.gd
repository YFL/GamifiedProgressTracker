class_name Entity extends RefCounted

var taskoid: Taskoid

func _init(taskoid: Taskoid) -> void:
  self.taskoid = taskoid

func should_be_drawn() -> bool:
  return true

func on_draw() -> void:
  pass

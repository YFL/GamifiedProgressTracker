class_name Entity extends RefCounted

var taskoid: Taskoid

func _init(taskoid: Taskoid) -> void:
  self.taskoid = taskoid

func should_be_drawn() -> bool:
  return true

func should_be_advanced() -> bool:
  return false

func on_draw() -> void:
  pass

func on_hide() -> void:
  pass

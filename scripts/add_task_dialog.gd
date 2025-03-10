class_name AddTaskDialog extends DialogBase

signal add_task(config: Taskoid.Config)

func _on_add_task_pressed() -> void:
  var config := Taskoid.Config.new(taskoid_name(), description(), difficulty(), parent(), false,
    has_deadline(), deadline())
  add_task.emit(config)

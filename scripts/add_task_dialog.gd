class_name AddTaskDialog extends TaskoidDialogBase

signal add_task(config: Taskoid.Config)

func _ready() -> void:
  _remove_invalid_difficulties()
  _difficulty.select(0)

func _remove_invalid_difficulties() -> void:
  while _difficulty.get_item_id(_difficulty.item_count - 1) > Difficulty.highest_task_difficulty():
    _difficulty.remove_item(_difficulty.item_count - 1)

func _on_add_task_pressed() -> void:
  var config := Taskoid.Config.new(taskoid_name(), description(), difficulty(), parent(), false,
    has_deadline(), deadline(), repetition_config())
  add_task.emit(config)

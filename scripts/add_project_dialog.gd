class_name AddProjectDialog extends TaskoidDialogBase

signal add_project(config: Taskoid.Config)

func _ready() -> void:
  super._ready()
  _difficulty.remove_item(0)
  _difficulty.select(0)

func _on_add_project_pressed() -> void:
  var config := Taskoid.Config.new(taskoid_name(), description(), difficulty(), parent(), false,
    has_deadline(), deadline(), repetition_config())
  add_project.emit(config)

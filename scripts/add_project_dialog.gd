class_name AddProjectDialog extends Control

signal add_project(name: String, description: String, parent: String, duration: int)

@onready var _project_name: TextEdit = $GridContainer/ProjectName
@onready var _description: TextEdit = $GridContainer/Description
@onready var _duration: DifficultyOptionButton = $GridContainer/Duration
@onready var _parent: ParentOptionButton = $GridContainer/Parent
@onready var _add_project: Button = $GridContainer/AddProject

func _ready() -> void:
  _duration.remove_item(0)

func _on_project_added(project: Project) -> void:
  _parent._on_project_added(project)

func _on_project_removed(project: Project) -> void:
  _parent._on_project_removed(project)

func project_name() -> String:
  return _project_name.text

func description() -> String:
  return _description.text

func duration() -> int:
  return _duration.get_item_id(_duration.selected)

func parent() -> String:
  if _parent.selected == -1 || _parent.selected == 0:
    return ""
  return _parent.get_item_text(_parent.selected)

func reset() -> void:
  _project_name.clear()
  _duration.select(0)
  _parent.select(0)

func _on_add_project_pressed() -> void:
  add_project.emit(project_name(), description(), parent(), duration())

func _on_project_name_text_changed() -> void:
  if _project_name.text.is_empty():
    _add_project.disabled = true
  elif _add_project.disabled:
    _add_project.disabled = false

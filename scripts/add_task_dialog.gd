class_name AddTaskDialog extends Control

signal add_task(name: String, description: String, parent: String, optional: bool, difficulty: int)

@onready var _task_name: TextEdit = $GridContainer/TaskName
@onready var _description: TextEdit = $GridContainer/Description
@onready var _difficulty: DifficultyOptionButton = $GridContainer/Difficulty
@onready var _parent: ParentOptionButton = $GridContainer/Parent
@onready var _optional: CheckButton = $GridContainer/Optional

func task_name() -> String:
  return _task_name.text

func description() -> String:
  return _description.text

func difficulty() -> int:
  return _difficulty.get_item_id(_difficulty.selected)

func optional() -> bool:
  return _optional.button_pressed

func parent_name() -> String:
  # Nothing selected or _None_ selected
  if _parent.selected == -1 || _parent.selected == 0:
    return ""
  return _parent.get_item_text(_parent.selected)
  
func reset() -> void:
  _task_name.clear()
  _description.clear()
  _difficulty.selected = 0
  _optional.button_pressed = false;
  _parent.select(0)

func _on_add_task_pressed() -> void:
  add_task.emit(task_name(), description(), parent_name(), optional(), difficulty())

func _on_project_added(project: Project) -> void:
  _parent._on_project_added(project)

func _on_project_removed(project: Project) -> void:
  _parent._on_project_removed(project)
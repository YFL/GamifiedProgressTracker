class_name AddTaskDialog extends DialogBase

signal add_task(name: String, description: String, parent: String, has_deadline: bool,
  deadline: String, difficulty: int)

@onready var _task_name: TextEdit = $GridContainer/TaskName
@onready var _description: TextEdit = $GridContainer/Description
@onready var _difficulty: DifficultyOptionButton = $GridContainer/Difficulty
@onready var _parent: ParentOptionButton = $GridContainer/Parent
@onready var _has_deadline: CheckButton = $GridContainer/HasDeadline
@onready var _deadline: DateControl = $GridContainer/Deadline

func _ready() -> void:
  _has_deadline.button_pressed = false
  _deadline.toggle(false)

func task_name() -> String:
  return _task_name.text

func description() -> String:
  return _description.text

func difficulty() -> int:
  return _difficulty.get_item_id(_difficulty.selected)

func parent_name() -> String:
  # Nothing selected or _None_ selected
  if _parent.selected == -1 || _parent.selected == 0:
    return ""
  return _parent.get_item_text(_parent.selected)

func has_deadline() -> bool:
  return _has_deadline.button_pressed

func deadline() -> String:
  return _deadline.date if has_deadline() else ""
  
func _reset() -> void:
  _task_name.clear()
  _description.clear()
  _difficulty.selected = 0
  _parent.select(0)

func _on_add_task_pressed() -> void:
  add_task.emit(task_name(), description(), parent_name(), has_deadline(), deadline(), difficulty())

func _on_project_added(project: Project) -> void:
  _parent._on_project_added(project)

func _on_project_removed(project: Project) -> void:
  _parent._on_project_removed(project)

func _on_has_deadline_toggled(toggled_on: bool) -> void:
  _deadline.toggle(toggled_on)

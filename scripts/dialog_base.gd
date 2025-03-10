class_name DialogBase extends Control

@onready var _taskoid_name: TextEdit = $GridContainer/Name
@onready var _description: TextEdit = $GridContainer/Description
@onready var _difficulty: DifficultyOptionButton = $GridContainer/Duration
@onready var _parent: ParentOptionButton = $GridContainer/Parent
@onready var _has_deadline: CheckButton = $GridContainer/HasDeadline
@onready var _deadline: DateControl = $GridContainer/Deadline
@onready var _add_taskoid: Button = $GridContainer/AddTaskoid

func _ready() -> void:
	_has_deadline.button_pressed = false
	_deadline.toggle(false)

func _reset() -> void:
	_taskoid_name.clear()
	_description.clear()
	_difficulty.select(0)
	_parent.select(0)
	_has_deadline.button_pressed = false
	_deadline.reset()

func taskoid_name() -> String:
	return _taskoid_name.text

func description() -> String:
	return _description.text

func difficulty() -> int:
	return _difficulty.get_selected_id()

func parent() -> String:
	return "" if _parent.selected == -1 || _parent.selected == 0\
		else _parent.get_item_text(_parent.selected)

func has_deadline() -> bool:
	return _has_deadline.button_pressed

func deadline() -> String:
	return _deadline.date if has_deadline() else ""

func _on_exit_button_pressed() -> void:
	hide()
	_reset()

func _on_project_added(project: Project) -> void:
	_parent._on_project_added(project)

func _on_project_removed(project: Project) -> void:
	_parent._on_project_removed(project)

func _on_has_deadline_toggled(toggled_on: bool) -> void:
	_deadline.toggle(toggled_on)

func _on_taskoid_name_text_changed() -> void:
	if _taskoid_name.text.is_empty():
		_add_taskoid.disabled = true
	elif _add_taskoid.disabled:
		_add_taskoid.disabled = false

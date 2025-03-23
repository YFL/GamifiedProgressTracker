class_name DialogBase extends ExitableBase

@onready var _taskoid_name: TextEdit = $GridContainer/Name
@onready var _description: TextEdit = $GridContainer/Description
@onready var _difficulty: DifficultyOptionButton = $GridContainer/Duration
@onready var _parent: ParentOptionButton = $GridContainer/Parent
@onready var _has_deadline: CheckButton = $GridContainer/HasDeadline
@onready var _deadline: DateControl = $GridContainer/Deadline
@onready var _does_repeat: CheckButton = $GridContainer/DoesRepeat
@onready var _add_taskoid: Button = $GridContainer/AddTaskoid

class RepetitionConfigDialogItems extends RefCounted:
	var starting_date_label := Label.new()
	var starting_date := DateControl.new()
	var interval_label := Label.new()
	var interval := IntervalControl.new()

	func _init() -> void:
		starting_date_label.text = "Starting date"
		interval_label.text = "Interval"

	func _notification(what: int) -> void:
		if what == NOTIFICATION_PREDELETE:
			starting_date_label.queue_free()
			starting_date.queue_free()
			interval_label.queue_free()
			interval.queue_free()

var _repetition_config := RepetitionConfigDialogItems.new()

func _ready() -> void:
	_has_deadline.button_pressed = false
	_deadline.toggle(false)
	_does_repeat.button_pressed = false

func _reset() -> void:
	_taskoid_name.clear()
	_description.clear()
	_difficulty.select(0)
	_parent.select(0)
	_has_deadline.button_pressed = false
	_deadline.reset()
	_does_repeat.button_pressed = false

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

func repetition_config() -> RepetitionConfig:
	if not _does_repeat.button_pressed:
		return null
	return RepetitionConfig.new(_repetition_config.starting_date.date, _repetition_config.interval.date)

func _on_exit_button_pressed() -> void:
	super._on_exit_button_pressed()
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

func _on_does_repeat_toggled(toggled_on: bool) -> void:
	if toggled_on:
		add_repetition_config_children()
	else:
		remove_repetition_config_children()

func add_repetition_config_children() -> void:
	_does_repeat.add_sibling(_repetition_config.starting_date_label)
	_repetition_config.starting_date_label.add_sibling(_repetition_config.starting_date)
	_repetition_config.starting_date.add_sibling(_repetition_config.interval_label)
	_repetition_config.interval_label.add_sibling(_repetition_config.interval)

func remove_repetition_config_children() -> void:
	remove_child(_repetition_config.starting_date_label)
	remove_child(_repetition_config.starting_date)
	remove_child(_repetition_config.interval_label)
	remove_child(_repetition_config.interval)
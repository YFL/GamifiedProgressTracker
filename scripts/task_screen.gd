class_name TaskScreen extends Control

@onready var task_name: TextEdit = $GridContainer/TaskName
@onready var description: TextEdit = $GridContainer/Description
@onready var difficulty: TextEdit = $GridContainer/Difficulty
@onready var parent: TextEdit = $GridContainer/Parent
@onready var optional: CheckButton = $GridContainer/Optional

func _on_exit_button_pressed() -> void:
	hide()

func set_task(task: Task) -> void:
	task_name.text = task.name
	description.text = task.description
	difficulty.text = Difficulty.difficulty_names[task.difficulty]
	parent.text = task.parent.name if task.parent else ""
	optional.button_pressed = task.optional
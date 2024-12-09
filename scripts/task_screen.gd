class_name TaskScreen extends Control

@onready var task_name: TextEdit = $GridContainer/TaskName
@onready var description: TextEdit = $GridContainer/Description
@onready var difficulty: TextEdit = $GridContainer/Difficulty
@onready var parent: TextEdit = $GridContainer/Parent
@onready var optional: CheckButton = $GridContainer/Optional

func _on_exit_button_pressed() -> void:
	hide()

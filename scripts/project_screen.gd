class_name ProjectScreen extends Control

@onready var project_name: TextEdit = $GridContainer/ProjectName
@onready var description: TextEdit = $GridContainer/Description
@onready var capacity: TextEdit = $GridContainer/Capacity
@onready var current_size: TextEdit = $GridContainer/Size
@onready var parent: TextEdit = $GridContainer/Parent


func _on_exit_button_pressed() -> void:
	hide()

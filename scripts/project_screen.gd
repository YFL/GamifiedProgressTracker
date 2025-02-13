class_name ProjectScreen extends Control

@onready var project_name: TextEdit = $GridContainer/ProjectName
@onready var description: TextEdit = $GridContainer/Description
@onready var capacity: TextEdit = $GridContainer/Capacity
@onready var current_size: TextEdit = $GridContainer/Size
@onready var parent: TextEdit = $GridContainer/Parent
@onready var complete_button: Button = $GridContainer/CompleteButton

var project: Project:
	set(to):
		project = to
		complete_button.disabled = true if project.completed else false
		project_name.text = project.name
		description.text = project.description
		capacity.text = Difficulty.difficulty_names[project.capacity]
		current_size.text =\
			Difficulty.difficulty_names[Difficulty.categorize_difficulty(project.children_difficulty)]
		parent.text = project.parent.name if project.parent else ""


func _on_exit_button_pressed() -> void:
	hide()

func _on_complete_button_pressed() -> void:
	if not project.complete():
		Globals.show_error_screen("Couldn't complete project. It either had some incomplete children" +
			", or it was already completed")
		return
	complete_button.disabled = true

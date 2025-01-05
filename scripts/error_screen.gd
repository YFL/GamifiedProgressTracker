class_name ErrorScreen extends Control

@onready var text: Label = $GridContainer/Label

func _on_exit_button_pressed() -> void:
  hide()
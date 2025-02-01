class_name DialogBase extends Control

func _reset() -> void:
	push_error("DialogBase._reset not implemented by inheriting scene!")

func _on_exit_button_pressed() -> void:
	hide()
	_reset()

class_name Globals extends Node

static var error_screen: ErrorScreen = preload("res://scenes/ErrorScreen.tscn").instantiate()

static func show_error_screen(error: String) -> void:
  error_screen.text.text = error
  error_screen.show()
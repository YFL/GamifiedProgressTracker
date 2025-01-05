class_name Result extends RefCounted

var result
var error: String

func _init(result, error: String = "") -> void:
  self.result = result
  self.error = error
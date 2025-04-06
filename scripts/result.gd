class_name Result extends RefCounted

var result
var error: String

static func Error(error: String) -> Result:
  return Result.new(null, error)

func _init(result, error: String = "") -> void:
  self.result = result
  self.error = error

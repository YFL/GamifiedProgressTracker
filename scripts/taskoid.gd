class_name Taskoid extends RefCounted

var name: String = ""
var description: String = ""
var parent: Project = null

func _init(name: String, description: String, parent: Project) -> void:
  self.name = name
  self.description = description
  self.parent = parent

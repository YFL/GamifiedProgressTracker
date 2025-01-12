class_name Taskoid extends RefCounted

const name_key = "name"
const description_key = "description"
const parent_name_key = "parent_name"

var name: String = ""
var description: String = ""
var parent: Project = null

func _init(name: String, description: String, parent: Project) -> void:
  self.name = name
  self.description = description
  self.parent = parent

func to_dict() -> Dictionary:
  return {
    name_key: name,
    description_key: description,
    parent_name_key: parent.name if parent != null else ""
  }
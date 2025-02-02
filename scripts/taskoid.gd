class_name Taskoid extends RefCounted

signal done(taskoid: Taskoid)

const name_key = "name"
const description_key = "description"
const parent_name_key = "parent_name"
const completed_key = "completed"

var name: String = ""
var description: String = ""
var parent: Project = null
var completed: bool = false

func _init(name: String, description: String, parent: Project) -> void:
  self.name = name
  self.description = description
  self.parent = parent

func complete() -> bool:
  if not completed:
    completed = true
    done.emit(self)
    return true
  return false

func to_dict() -> Dictionary:
  return {
    name_key: name,
    description_key: description,
    parent_name_key: parent.name if parent != null else "",
    completed_key: completed
  }
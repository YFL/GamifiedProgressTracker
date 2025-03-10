class_name Taskoid extends RefCounted

signal done(taskoid: Taskoid)

var name: String = ""
var description: String = ""
var difficulty: int = Difficulty.Invalid
var parent: Project = null
var completed: bool = false
var has_deadline: bool = false
var deadline: String = ""

class Params extends RefCounted:
  var name: String = ""
  var description: String = ""
  var difficulty: int = Difficulty.Invalid
  var parent: Project = null
  var has_deadline: bool = false
  var deadline: String = ""

  func _init(name: String, description: String, difficulty: int, parent: Project,
    has_deadline: bool, deadline: String) -> void:
    self.name = name
    self.description = description
    self.difficulty = difficulty
    self.parent = parent
    self.has_deadline = has_deadline
    self.deadline = deadline
  
class Config extends RefCounted:
  
  const name_key = "name"
  const description_key = "description"
  const difficulty_key = "difficulty"
  const parent_name_key = "parent_name"
  const completed_key = "completed"
  const has_deadline_key = "has_deadline"
  const deadline_key = "deadline"

  var name: String = ""
  var description: String = ""
  var difficulty: int = Difficulty.Invalid
  var parent: String = ""
  var completed: bool = false
  var has_deadline: bool = false
  var deadline: String = ""

  func _init(name: String, description: String, difficulty: int, parent: String, completed: bool,
    has_deadline: bool, deadline: String) -> void:
    self.name = name
    self.description = description
    self.difficulty = difficulty
    self.parent = parent
    self.completed = completed
    self.has_deadline = has_deadline
    self.deadline = deadline
  
  func to_dict() -> Dictionary:
    return {
      name_key: name,
      description_key: description,
      difficulty_key: difficulty,
      parent_name_key: parent,
      completed_key: completed,
      has_deadline_key: has_deadline,
      deadline_key: deadline
    }

func _init(param: Params) -> void:
  self.name = param.name
  self.description = param.description
  self.difficulty = param.difficulty
  self.parent = param.parent
  self.has_deadline = param.has_deadline
  self.deadline = param.deadline

func complete() -> Result:
  if not completed:
    completed = true
    done.emit(self)
    return Result.new(true)
  return Result.new(false, "Taskoid already completed")

func config() -> Config:
  return Config.new(name, description, difficulty, (parent.name if parent != null else ""),
    completed, has_deadline, deadline)

static func config_from_dict(dict: Dictionary) -> Result:
  const name_key = "name"
  var name = dict.get(name_key, null)
  if name == null:
    return Result.new(null, "Taskoid name missing")
  if typeof(name) != TYPE_STRING:
    return Result.new(null, "Taskoid name is not a string")
  if name.is_empty():
    return Result.new(null, "Tasoidk name is empty")
  const description_key = "description"
  var description = dict.get(description_key, null)
  if description == null:
    return Result.new(null, "Taskoid description missing")
  if typeof(description) != TYPE_STRING:
    return Result.new(null, "Taskoid description is not a string")
  const difficulty_key = "difficulty"
  var difficulty = dict.get(difficulty_key, null)
  if difficulty == null:
    return Result.new(null, "Taskoid difficulty missing")
  if typeof(difficulty) != TYPE_FLOAT:
    return Result.new(null, "Taskoid difficulty is not a number")
  const parent_name_key = "parent_name"
  var parent = dict.get(parent_name_key, null)
  if parent == null:
    return Result.new(null, "Taskoid parent name is missing")
  if typeof(parent) != TYPE_STRING:
    return Result.new(null, "Taskoid parent name is not a string")
  const completed_key = "completed"
  var completed = dict.get(completed_key, null)
  if completed == null:
    return Result.new(null, "Taskoid completed missing")
  if typeof(completed) != TYPE_BOOL:
    return Result.new(null, "Taskoid completed is not a bool")
  const has_deadline_key = "has_deadline"
  var has_deadline = dict.get(has_deadline_key, null)
  if has_deadline == null:
    return Result.new(null, "Taskoid has deadline is missing")
  if typeof(has_deadline) != TYPE_BOOL:
    return Result.new(null, "Taskoid has deadline is not a bool")
  const deadline_key = "deadline"
  var deadline = dict.get(deadline_key, null)
  if deadline == null:
    return Result.new(null, "Taskoid deadline is missing")
  if typeof(deadline) != TYPE_STRING:
    return Result.new(null, "Taskoid deadline is not a string")
  return Result.new(Config.new(name, description, difficulty, parent, completed, has_deadline,
    deadline))
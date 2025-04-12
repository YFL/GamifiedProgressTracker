class_name Taskoid extends RefCounted

signal done(taskoid: Taskoid)

var name: String = ""
var description: String = ""
var difficulty: int = Difficulty.Invalid
var parent: Project = null
var completed: bool = false
var has_deadline: bool = false
var deadline: Date
var repetition_config: RepetitionConfig = null

class Params extends RefCounted:
  var name: String = ""
  var description: String = ""
  var difficulty: int = Difficulty.Invalid
  var parent: Project = null
  var has_deadline: bool = false
  var deadline: Date
  var repetition_config: RepetitionConfig = null

  func _init(name: String, description: String, difficulty: int, parent: Project,
    has_deadline: bool, deadline: Date, repetition_config: RepetitionConfig) -> void:
    self.name = name
    self.description = description
    self.difficulty = difficulty
    self.parent = parent
    self.has_deadline = has_deadline
    self.deadline = deadline
    self.repetition_config = repetition_config
  
class Config extends RefCounted:
  
  const name_key = "name"
  const description_key = "description"
  const difficulty_key = "difficulty"
  const parent_name_key = "parent_name"
  const completed_key = "completed"
  const has_deadline_key = "has_deadline"
  const deadline_key = "deadline"
  const repetition_config_key = "repetition_config_key"

  var name: String = ""
  var description: String = ""
  var difficulty: int = Difficulty.Invalid
  var parent: String = ""
  var completed: bool = false
  var has_deadline: bool = false
  var deadline: Date = null
  var repetition_config: RepetitionConfig = null

  func _init(name: String, description: String, difficulty: int, parent: String, completed: bool,
    has_deadline: bool, deadline: Date, repetition_config: RepetitionConfig) -> void:
    self.name = name
    self.description = description
    self.difficulty = difficulty
    self.parent = parent
    self.completed = completed
    self.has_deadline = has_deadline
    self.deadline = deadline
    self.repetition_config = repetition_config
  
  func to_dict() -> Dictionary:
    return {
      name_key: name,
      description_key: description,
      difficulty_key: difficulty,
      parent_name_key: parent,
      completed_key: completed,
      has_deadline_key: has_deadline,
      deadline_key: deadline.to_dict(),
      repetition_config_key: repetition_config.to_dict() if repetition_config else {}
    }

func _init(param: Params) -> void:
  self.name = param.name
  self.description = param.description
  self.difficulty = param.difficulty
  self.parent = param.parent
  self.has_deadline = param.has_deadline
  self.deadline = param.deadline
  self.repetition_config = param.repetition_config

func complete() -> Result:
  if not completed:
    completed = true
    done.emit(self)
    if repetition_config:
      deadline.add_interval(repetition_config.interval)
    return Result.new(true)
  return Result.new(false, "Taskoid already completed")

func prepare_to_be_repeated() -> void:
  if completed:
    completed = false
  else:
    # Since the deadline is only updated, if the taskoid was completed, we have to update it here
    deadline.add_interval(repetition_config.interval)
  repetition_config.advance()

func config() -> Config:
  return Config.new(name, description, difficulty, (parent.name if parent != null else ""),
    completed, has_deadline, deadline, repetition_config)

static func config_from_dict(dict: Dictionary) -> Result:
  const name_key = "name"
  var name = dict.get(name_key)
  if name == null:
    return Result.Error("Taskoid name missing")
  if typeof(name) != TYPE_STRING:
    return Result.Error("Taskoid name is not a string")
  if name.is_empty():
    return Result.Error("Tasoidk name is empty")
  const description_key = "description"
  var description = dict.get(description_key)
  if description == null:
    return Result.Error("Taskoid description missing")
  if typeof(description) != TYPE_STRING:
    return Result.Error("Taskoid description is not a string")
  const difficulty_key = "difficulty"
  var difficulty = dict.get(difficulty_key)
  if difficulty == null:
    return Result.Error("Taskoid difficulty missing")
  if typeof(difficulty) != TYPE_FLOAT:
    return Result.Error("Taskoid difficulty is not a number")
  const parent_name_key = "parent_name"
  var parent = dict.get(parent_name_key)
  if parent == null:
    return Result.Error("Taskoid parent name is missing")
  if typeof(parent) != TYPE_STRING:
    return Result.Error("Taskoid parent name is not a string")
  const completed_key = "completed"
  var completed = dict.get(completed_key)
  if completed == null:
    return Result.Error("Taskoid completed missing")
  if typeof(completed) != TYPE_BOOL:
    return Result.Error("Taskoid completed is not a bool")
  const has_deadline_key = "has_deadline"
  var has_deadline = dict.get(has_deadline_key)
  if has_deadline == null:
    return Result.Error("Taskoid has deadline is missing")
  if typeof(has_deadline) != TYPE_BOOL:
    return Result.Error("Taskoid has deadline is not a bool")
  const deadline_key = "deadline"
  var deadline_res = Date.from_dict(dict.get(deadline_key))
  if deadline_res.result == null:
    return Result.Error("Taskoid deadline is invalid: " + deadline_res.error)
  var repetition_config_res := RepetitionConfig.from_dict(dict.get(Config.repetition_config_key, {}))
  if repetition_config_res.result == null and not repetition_config_res.error.is_empty():
    return Result.Error("Taskoid repetition config is invalid: " + repetition_config_res.error)
  return Result.new(Config.new(name, description, difficulty, parent, completed, has_deadline,
    deadline_res.result, repetition_config_res.result))
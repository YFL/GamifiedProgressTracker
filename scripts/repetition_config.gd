class_name RepetitionConfig extends RefCounted

const type_key := "type"
const starting_date_key := "starting_date_key"
const interval_key := "interval"

# This is the date, when the task will have to be visible the next time.
var next_starting_date: Date
# This is the date, when the task was made visible; this is stored when saved.
var current_starting_date: Date
var interval: Date
var type: String = "Invalid"

## """
## Returns a repetition config in the result, if the operation was successfull AND a non empty
## repetition config was found.
## Returns null and an empty error message if an empty repetition config was found.
## Returns null and a non empty error message if an invalid repetition config was found.
## """
static func from_dict(dict: Dictionary) -> Result:
  if not dict.size():
    return Result.new(null)
  var type = dict.get(type_key)
  if type == null:
    return Result.Error("Type missing")
  if typeof(type) != TYPE_STRING:
    return Result.Error("Type is not a string")
  var starting_date_dict = dict.get(starting_date_key)
  if starting_date_dict == null:
    return Result.Error("Starting date missing")
  if typeof(starting_date_dict) != TYPE_DICTIONARY:
    return Result.Error("Starting date is not a dictionary")
  var is_starting_date_dict_valid = Date.check_dict(starting_date_dict)
  if not is_starting_date_dict_valid.result:
    return Result.Error("Starting date invalid: " + is_starting_date_dict_valid.error)
  var interval_dict = dict.get(interval_key)
  if interval_dict == null:
    return Result.Error("Interval missing")
  if typeof(interval_dict) != TYPE_DICTIONARY:
    return Result.Error("Interval is not a dictionary")
  var is_interval_dict_valid = Date.check_dict(interval_dict)
  if not is_interval_dict_valid.result:
    return Result.Error("Interval invalid: " + is_interval_dict_valid.error)
  return Result.new(RepetitionConfig.new(
    Date.new(starting_date_dict),
    Date.new(interval_dict),
    type))

func _init(starting_date: Date, interval: Date, type: String = "Invalid") -> void:
  self.current_starting_date = Date.new(starting_date.to_dict())
  self.next_starting_date = Date.new(current_starting_date.to_dict())
  var dict_from_system = Time.get_date_dict_from_system()
  var date_from_system_result := Date.new(dict_from_system)
  var date_from_system: Date = date_from_system_result
  while date_from_system.gt(next_starting_date):
    self.next_starting_date.add_interval(interval)
  self.interval = interval
  self.type = type

func can_contain(repetition_config: RepetitionConfig) -> bool:
  return repetition_config.type == type

func advance() -> void:
  current_starting_date = Date.new(next_starting_date.to_dict())
  next_starting_date.add_interval(interval)

func to_dict() -> Dictionary:
  return {
    type_key: type,
    starting_date_key: current_starting_date.to_dict(),
    interval_key: interval.to_dict()
  }

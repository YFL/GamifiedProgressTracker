class_name RepetitionConfig extends RefCounted

const year_key := "year"
const month_key := "month"
const day_key := "day"
const type_key := "type"
const starting_date_key := "starting_date_key"
const interval_key := "interval"

var starting_date: Date
var interval: Interval
var type: String = "Invalid"

func _init(starting_date: Date, interval: Interval, type: String = "Invalid") -> void:
  self.starting_date = starting_date
  self.interval = interval
  self.type = type

func can_contain(repetition_config: RepetitionConfig) -> bool:
  return repetition_config.type == type

func advance() -> void:
  starting_date.add_interval(interval)

func to_dict() -> Dictionary:
  return {
    type_key: type,
    starting_date_key: starting_date.to_int(),
    interval_key: interval.to_int()
  }

static func from_dict(dict: Dictionary) -> Result:
  var type = dict.get(type_key)
  if type == null:
    return Result.new(null, "Type missing")
  if typeof(type) != TYPE_STRING:
    return Result.new(null, "Type is not a string")
  var starting_date = dict.get(starting_date_key)
  if starting_date == null:
    return Result.new(null, "Starting date missing")
  if typeof(starting_date) != TYPE_FLOAT:
    return Result.new(null, "Starting date is not a number")
  var interval = dict.get(interval_key)
  if interval == null:
    return Result.new(null, "Interval missing")
  if typeof(interval) != TYPE_FLOAT:
    return Result.new(null, "Interval is not a number")

  return Result.new(RepetitionConfig.new(
    Date.from_int(starting_date),
    Interval.from_int(interval),
    type))
class_name RepetitionConfig extends RefCounted

const year_key := "year"
const month_key := "month"
const day_key := "day"
const type_key := "type"
const starting_date_key := "starting_date_key"
const interval_key := "interval"

var starting_date: String = ""
var interval: String = ""
var type: String = "Invalid"

func _init(next_starting_date: String, interval: String, type: String = "Invalid") -> void:
  self.starting_date = next_starting_date
  self.interval = interval
  self.type = type

func can_contain(repetition_config: RepetitionConfig) -> bool:
  return repetition_config.type == type

## Computes the next starting date and the next deadline
## deadline is advanced by interval and the result is returned
func advance_deadline(deadline: String) -> String:
  var deadline_date_time := Time.get_datetime_dict_from_datetime_string(deadline, false)
  var interval_date_time := Time.get_datetime_dict_from_datetime_string(interval, false)
  return Time.get_datetime_string_from_datetime_dict(
    add_dates(deadline_date_time, interval_date_time), false)

func advance() -> void:
  var starting_date_dict :=\
    Time.get_datetime_dict_from_datetime_string(starting_date, false)
  var interval_date_time := Time.get_datetime_dict_from_datetime_string(interval, false)
  starting_date = Time.get_datetime_string_from_datetime_dict(
    add_dates(starting_date_dict, interval_date_time), false)

func add_dates(l: Dictionary, r: Dictionary) -> Dictionary:
  var year := l[year_key] + r[year_key] as int
  var month := l[month_key] + r[month_key] as int
  var day := l[day_key] + r[day_key] as int
  if month > Time.MONTH_DECEMBER:
    month -= Time.MONTH_DECEMBER
    year += 1
  var months_of_30_days: Array[Time.Month] = [Time.MONTH_APRIL, Time.MONTH_JUNE,
    Time.MONTH_SEPTEMBER, Time.MONTH_NOVEMBER]
  var days_in_month := 31
  if month == Time.MONTH_FEBRUARY:
    days_in_month = 28 if year % 4 else 29
  elif months_of_30_days.has(month):
    days_in_month = 30
  if day > days_in_month:
    day -= days_in_month
    month += 1
  return {
    year: year,
    month: month,
    day: day
  }

func to_dict() -> Dictionary:
  return {
    type_key: type,
    starting_date_key: starting_date,
    interval_key: interval
  }

static func from_dict(dict: Dictionary) -> Result:
  var type = dict.get(type_key)
  if type == null:
    return Result.new(null, "Type missing")
  if typeof(type) != TYPE_STRING:
    return Result.new(null, "Type is not a string")
  var starting_date = dict.get(starting_date_key)
  if starting_date == null:
    return Result.new(null, "Current starting date missing")
  if typeof(starting_date) != TYPE_STRING:
    return Result.new(null, "Current starting date is not a string")
  var interval = dict.get(interval_key)
  if interval == null:
    return Result.new(null, "Interval missing")
  if typeof(interval) != TYPE_STRING:
    return Result.new(null, "Interval is not a string")

  return Result.new(RepetitionConfig.new(starting_date, interval, type))
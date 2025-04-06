class_name Date extends RefCounted

const year_key := "year"
const month_key := "month"
const day_key := "day"

var _date: Dictionary

static func _check_dict(dict: Dictionary) -> Result:
  var year = dict.get(year_key)
  if year == null:
    return Result.Error("Year is missing")
  if typeof(year) != TYPE_FLOAT and typeof(year) != TYPE_INT:
    return Result.Error("Year is not a number")
  var month = dict.get(month_key)
  if month == null:
    return Result.Error("Month is missing")
  if typeof(month) != TYPE_FLOAT and typeof(month) != TYPE_INT:
    return Result.Error("Month is not a number")
  var day = dict.get(day_key)
  if day == null:
    return Result.Error("Day is missing")
  if typeof(day) != TYPE_FLOAT and typeof(day) != TYPE_INT:
    return Result.Error("Day is not a number")
  return Result.new(true)

static func from_dict(dict: Dictionary) -> Result:
  return Result.new(Date.new(dict))

func _init(date: Dictionary) -> void:
  var res := _check_dict(date)
  if not res.result:
    push_error("Couldn't create date: " + res.error)
    return
  _date = date

func gt(date: Date) -> bool:
  if date._date[year_key] < _date[year_key]:
    return true
  if date._date[month_key] < _date[month_key]:
    return true
  if date._date[day_key] < _date[day_key]:
    return true
  return false

func eq(date: Date) -> bool:
  return date._date[year_key] == _date[year_key] and date._date[month_key] == _date[month_key] and \
    date._date[day_key] == _date[day_key]

func gte(date: Date) -> bool:
  return gt(date) or eq(date)

func to_dict() -> Dictionary:
  return _date

func add_interval(interval: Date) -> void:
  var year: int = _date.year + interval._date.year
  var month: int = _date.month + interval._date.month
  if month > 12:
    year += month / 12
    month = month % 12
  var day: int = _date.day + interval._date.day
  var days_in_month := {
    1: 31,
    2: 28 if year % 4 else 29,
    3: 31,
    4: 30,
    5: 31,
    6: 30,
    7: 31,
    8: 31,
    9: 30,
    10: 31,
    11: 30,
    12: 31
  }

  while day > days_in_month[month]:
    day -= days_in_month[month]
    month += 1
  
  _date = {
    year = year,
    month = month,
    day = day
  }

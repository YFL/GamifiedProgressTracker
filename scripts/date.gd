class_name Date extends RefCounted

var _date: int = 0

static func from_int(number: int) -> Date:
  var date := Date.new({year = 0, month = 0, day = 0})
  date._date = number
  return date

func _init(date: Dictionary) -> void:
  if not date.get("year") or not date.get("month") or not date.get("day"):
    return
  _date = Time.get_unix_time_from_datetime_dict(date)

func gt(date: Date) -> bool:
  return date._date < _date

func gte(date: Date) -> bool:
  return date._date <= _date

func to_dict() -> Dictionary:
  return Time.get_datetime_dict_from_unix_time(_date)

func to_int() -> int:
  return _date

func add_interval(interval: Interval) -> void:
  _date += interval._interval
class_name Interval extends RefCounted

var _interval: int = 0

static func from_int(interval: int) -> Interval:
  var ret := Interval.new({year = 0, month = 0, day = 0})
  ret._interval = interval
  return ret

func _init(interval: Dictionary) -> void:
  if not interval.get("year") or not interval.get("month") or not interval.get("day"):
    return
  interval.year += 1970
  interval.month += 1
  interval.day += 1
  _interval = Time.get_unix_time_from_datetime_dict(interval)

func gt(interval: Interval) -> bool:
  return interval._interval < _interval

func gte(interval: Interval) -> bool:
  return interval._interval <= _interval

func to_dict() -> Dictionary:
  var dict := Time.get_datetime_dict_from_unix_time(_interval)
  return {
    year = dict.year - 1970,
    month = dict.month - 1,
    day = dict.day - 1
  }

func to_int() -> int:
  return _interval

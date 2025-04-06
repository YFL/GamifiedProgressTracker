class_name IntervalControl extends DateControl

func _init() -> void:
  year.min_value = 0
  year.max_value = 9999
  month.min_value = 0
  month.max_value = 12
  day.min_value = 0
  day.max_value = 31
  reset()

func reset() -> void:
  year.value = 0
  month.value = 0
  day.value = 1
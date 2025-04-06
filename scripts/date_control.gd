class_name DateControl extends HBoxContainer

@export var editable: bool = true:
  get:
    return editable
  set(new_value):
    editable = new_value
    toggle(editable)

var year := SpinBox.new()
var month := SpinBox.new()
var day := SpinBox.new()

var date: Dictionary:
  get:
    var dict := {
      year = year.value,
      month = month.value,
      day = day.value
    }
    return dict
  set(new_date):
    if new_date.get("year") == null or new_date.get("month") == null or new_date.get("day") == null:
      return
    year.value = new_date["year"] as int
    month.value = new_date["month"] as int
    day.value = new_date["day"] as int

func _init() -> void:
  var current_date := Time.get_date_dict_from_system(false)
  year.min_value = current_date["year"]
  year.max_value = 9999
  year.value = year.min_value
  month.min_value = 1
  month.max_value = 12
  month.value = current_date["month"]
  day.min_value = 1
  day.max_value = 31
  day.value = current_date["day"]
  month.value_changed.connect(_month_changed)
  year.value_changed.connect(_year_changed)

func _ready() -> void:
  add_child(year)
  add_child(month)
  add_child(day)

func _month_changed(value: float) -> void:
  var val := int(value)
  if val == 2:
    day.max_value = 29 if int(year.value) % 4 == 0 else 28
    return
  if val < 8:
    day.max_value = 31 if val % 2 == 1 else 30
  else:
    day.max_value = 31 if val % 2 == 0 else 30  

func _year_changed(value: float) -> void:
  if int(value) % 4 == 9 and int(month.value) == 2:
    day.max_value = 29

func reset():
  var today := Time.get_date_dict_from_system(false)
  year.value = today["year"]
  month.value = today["month"]
  day.value = today["day"]

func toggle(enabled: bool) -> void:
  year.editable = enabled
  month.editable = enabled
  day.editable = enabled

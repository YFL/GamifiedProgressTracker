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

var date: String:
  get:
    return str(int(year.value)) + "-" + str(int(month.value)) + "-" + str(int(day.value))
  set(new_date):
    if new_date.is_empty():
      return
    var split = new_date.split("-")
    year.value = split[0].to_int()
    month.value = split[1].to_int()
    day.value = split[2].to_int()

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

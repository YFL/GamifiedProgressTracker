class_name AddTaskDialog extends Control

signal add_task(name: String, parent: String, optional: bool, difficulty: Task.TaskDifficulty)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
  visible = false
  ($Parent as OptionButton).add_item("None")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
  pass

func _on_texture_button_pressed() -> void:
  visible = true

func _on_add_task_pressed() -> void:
  visible = false
  add_task.emit(task_name(), parent_name(), optional(), difficulty())
  reset()

func _on_task_added(task: Task) -> void:
  var parent_button: OptionButton = $Parent
  parent_button.add_item(task.name)
  sort_parents()

func _on_task_removed(task: Task) -> void:
  var parent_button: OptionButton = $Parent
  for i: int in parent_button.get_child_count():
    if parent_button.get_item_text(i) == task.name:
      parent_button.remove_item(i)
      break

func task_name() -> String:
  return ($TaskName as TextEdit).text

func difficulty() -> Task.TaskDifficulty:
  var option_button: OptionButton = $Difficulty
  return option_button.get_item_id(option_button.selected) as Task.TaskDifficulty

func optional() -> bool:
  return ($Optional as CheckButton).button_pressed

func parent_name() -> String:
  var parent_button: OptionButton = $Parent
  # Nothing selected or _None_ selected
  if parent_button.selected == -1 || parent_button.selected == 0:
    return ""
  return parent_button.get_item_text(parent_button.selected)
  
func reset() -> void:
  ($TaskName as TextEdit).clear()
  ($Difficulty as OptionButton).selected = 0
  ($Optional as CheckButton).button_pressed = false;
  ($Parent as OptionButton).selected = -1

func sort_parents() -> void:
  var parents: OptionButton = $Parent
  var sorted: Array[String]
  parents.remove_item(0)
  for i: int in parents.item_count:
    sorted.append(parents.get_item_text(i))

  parents.clear()

  sorted.sort()
  parents.add_item("None")
  for task: String in sorted:
    parents.add_item(task)
  
class_name ParentOptionButton extends OptionButton

func _init() -> void:
  add_item("None")

func _on_project_added(project: Project) -> void:
  var current := get_item_text(selected)
  var current_idx := selected
  add_item(project.name)
  sort_parents()
  if get_item_text(current_idx) == current:
    select(current_idx)
  else:
    select(current_idx + 1)
  

func _on_project_removed(project: Project) -> void:
  for i: int in get_child_count():
    if get_item_text(i) == project.name:
      if i == selected:
        select(0)
      remove_item(i)
      break

func sort_parents() -> void:
  var sorted: Array[String]
  remove_item(0)
  for i: int in item_count:
    sorted.append(get_item_text(i))

  clear()

  sorted.sort()
  add_item("None")
  for project: String in sorted:
    add_item(project)
 
func clear_added():
  clear()
  add_item("None")
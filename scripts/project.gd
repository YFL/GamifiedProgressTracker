class_name Project extends RefCounted

var name := ""
var capacity := Difficulty.Invalid
var parent: Project = null
## Array of projects and tasks
var children: Array = []
var children_difficulty: int = Difficulty.Invalid

func _init(name: String, parent: Project, capacity: int) -> void:
  if capacity < Difficulty.Medium:
    return
  self.name = name
  self.parent = parent
  if parent != null:
    parent.add_project(self)
  self.capacity = capacity

func _to_string() -> String:
  return name + " " + (parent.name + " " if parent != null else "None ") + Difficulty.difficulty_names[capacity]

func add_task(child: Task) -> void:
  if not can_fit(child.difficulty):
    return
  children.append(child)
  if child.optional:
    return
  children_difficulty += child.difficulty
  add_child_difficulty_to_parent(child.difficulty)

func add_project(child: Project) -> void:
  if not can_fit(child.children_difficulty):
    return
  children.append(child)
  children_difficulty += child.children_difficulty
  add_child_difficulty_to_parent(child.children_difficulty)
  
func remove_task(child: Task) -> void:
  if children.find(child) < 0:
    return
  children.erase(child)
  if not child.optional:
    children_difficulty -= child.difficulty
    add_child_difficulty_to_parent(-child.difficulty)

func remove_project(child: Project) -> void:
  if children.find(child) < 0:
    return
  children.erase(child)
  children_difficulty -= child.children_difficulty
  add_child_difficulty_to_parent(-child.children_difficulty)

func can_fit(difficulty: int) -> bool:
  return children_difficulty + difficulty <= capacity

func add_child_difficulty_to_parent(difficulty: int) -> void:
  if parent == null:
    return
  parent.children_difficulty += difficulty
  parent.add_child_difficulty_to_parent(difficulty)
class_name Project extends Taskoid

var capacity := Difficulty.Invalid
## Array of projects and tasks
var children: Array = []
var children_difficulty: int = Difficulty.Invalid

func _init(name: String, description: String, parent: Project, capacity: int) -> void:
  if capacity < Difficulty.NoteWorthy:
    return
  super._init(name, description, parent)
  if parent != null:
    parent.add_project(self)
  self.capacity = capacity

func _to_string() -> String:
  return name + " Description: " + description + " Parent: " +\
    (parent.name + " " if parent != null else "None ") + " Difficulty: "\
    + Difficulty.difficulty_names[capacity]

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
  if parent != null:
    return parent.can_fit(difficulty) && children_difficulty + difficulty <= capacity
  return children_difficulty + difficulty <= capacity

func add_child_difficulty_to_parent(difficulty: int) -> void:
  if parent == null:
    return
  parent.children_difficulty += difficulty
  parent.add_child_difficulty_to_parent(difficulty)

class_name Project extends Taskoid

## Array of projects and tasks
var children: Array[Taskoid] = []
var children_difficulty: int = Difficulty.Invalid

func _init(params: Taskoid.Params) -> void:
  if params.difficulty < Difficulty.NoteWorthy:
    return
  super._init(params)
  if parent != null:
    parent.add_project(self)

func _to_string() -> String:
  return name + " Description: " + description + " Parent: " +\
    (parent.name + " " if parent != null else "None ") + " Difficulty: "\
    + Difficulty.difficulty_names[difficulty]

func add_task(child: Task) -> void:
  if not can_fit(child.difficulty):
    return
  children.append(child)
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
    return parent.can_fit(difficulty) && children_difficulty + difficulty <= self.difficulty
  return children_difficulty + difficulty <= self.difficulty

func add_child_difficulty_to_parent(difficulty: int) -> void:
  if parent == null:
    return
  parent.children_difficulty += difficulty
  parent.add_child_difficulty_to_parent(difficulty)

func complete() -> Result:
  for child in children:
    if not child.completed:
      return Result.new(false, child.name + " is not completed yet")
  return super.complete()
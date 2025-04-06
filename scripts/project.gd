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

func add_child_taskoid(taskoid: Taskoid, difficulty: int) -> void:
  if not can_fit(taskoid.difficulty):
    return
  children.append(taskoid)
  children_difficulty += difficulty
  add_child_difficulty_to_parent(difficulty)
  if repetition_config:
    taskoid.repetition_config = repetition_config
  if has_deadline and taskoid.has_deadline:
    if taskoid.deadline.gt(deadline):
      taskoid.deadline = deadline

func add_task(child: Task) -> void:
  add_child_taskoid(child, child.difficulty)

func add_project(child: Project) -> void:
  add_child_taskoid(child, child.children_difficulty)

func remove_child_taskoid(taskoid: Taskoid, difficulty: int) -> void:
  var index := children.find(taskoid)
  if index < 0:
    return
  children.remove_at(index)
  children_difficulty -= difficulty
  add_child_difficulty_to_parent(-difficulty)

func remove_task(child: Task) -> void:
  remove_child_taskoid(child, child.difficulty)

func remove_project(child: Project) -> void:
  remove_child_taskoid(child, child.children_difficulty)

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

func prepare_to_be_repeated() -> void:
  super.prepare_to_be_repeated()
  for child in children:
    child.prepare_to_be_repeated()
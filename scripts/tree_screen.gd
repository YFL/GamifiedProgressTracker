class_name TreeScreen extends ExitableBase

@onready var taskoid_tree: Tree = $TaskoidTree
@onready var task_screen: TaskoidScreenBase =\
  preload("res://scenes/TaskoidScreenBase.tscn").instantiate()
@onready var project_screen: ProjectScreen =\
  preload("res://scenes/ProjectScreen.tscn").instantiate()
@onready var texture: Texture2D = preload("res://textures/HamburgerNormal.png")

func _ready() -> void:
  taskoid_tree.create_item()
  task_screen.hide()
  project_screen.hide()
  add_child(task_screen)
  add_child(project_screen)
  task_screen.position = Vector2(size.x + position.x, 0)
  project_screen.position = Vector2(size.x + position.x, 0)
  taskoid_tree.button_clicked.connect(handle_button_click)
  var img := texture.get_image()
  img.resize(30, 30)
  texture = ImageTexture.create_from_image(img)

func add_taskoid(taskoid: Taskoid) -> void:
  var root := taskoid_tree.get_root()
  var parents: Array[Taskoid]
  var iterator := taskoid.parent
  while iterator != null:
    parents.push_back(iterator)
    iterator = iterator.parent
  var current_item := root
  for i in range(parents.size() - 1, -1, -1):
    current_item = current_item.get_first_child()
    while current_item.get_metadata(0) != parents[i]:
      current_item = current_item.get_next()
      if current_item == null:
        push_error("Can't find the right branch in the taskoid tree for the new taskoid")
        return
  var child := current_item.create_child()
  child.set_metadata(0, taskoid)
  child.set_text(0, taskoid.name)
  child.add_button(0, texture, -1, false, "Click here to see details")

func handle_button_click(item: TreeItem, column: int, id: int, mouse_button_index: int) -> void:
  var taskoid: Taskoid = item.get_metadata(0)
  if task_screen.visible and task_screen.task_name.text == taskoid.name:
    task_screen.hide()
    return
  if project_screen.visible and project_screen.project == taskoid:
    project_screen.hide()
    return
  if taskoid is Task:
    task_screen.set_taskoid(taskoid as Task)
    task_screen.show()
    project_screen.hide()
  else:
    project_screen.set_taskoid(taskoid as Project)
    task_screen.hide()
    project_screen.show()

class_name Tasks extends ScrollContainer

const TaskListItemScn = preload("res://scenes/TaskListItem.tscn")
@onready var vbox: VBoxContainer = $TasksVBox

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
  pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
  pass


func _on_task_added(task: Task) -> void:
  var list_item: TaskListItem = TaskListItemScn.instantiate()
  list_item.custom_init(task)
  vbox.add_child(list_item)

func _on_task_removed(task: Task) -> void:
  for child: TaskListItem in vbox.get_children():
    if child.task == task:
      vbox.remove_child(child)
      child.queue_free()
      break

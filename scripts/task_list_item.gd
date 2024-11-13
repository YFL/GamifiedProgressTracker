class_name TaskListItem extends Control


@onready var task_name: Label = $Name
@onready var done: CheckButton = $Done

var task: Task

func custom_init(task: Task) -> void:
  self.task = task

func _ready() -> void:
  task_name.text = task.name
  done.button_pressed = task.completed

func _on_done_pressed() -> void:
  done.disabled = true
  task.complete()

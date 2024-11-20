class_name TaskBank extends RefCounted

signal task_added(task: Task)
signal task_removed(task: Task)

var tasks: Dictionary

func create(name: String, parent: Task, optional: bool, difficulty: Task.TaskDifficulty) -> Task:
  if tasks.has(name):
    return null
  var task := Task.new(name, parent, optional, difficulty)
  tasks[name] = task
  print("Task \"" + str(task) + "\" added")
  task_added.emit(task)
  return task

func get_task(task_name: String) -> Task:
  return tasks.get(task_name)

func get_tasks() -> Array[Task]:
  var tasks: Array[Task]
  for key: String in self.tasks:
    tasks.append(self.tasks[key])
  return tasks

func has(task_name: String) -> bool:
  return tasks.has(task_name)

func has_task(task: Task) -> bool:
  return has(task.name)

func remove(task_name: String) -> void:
  var task: Task = tasks.get(task_name)
  if task == null:
    return
  tasks.erase(task_name)
  task_removed.emit(task)

func remove_task(task: Task) -> void:
  remove(task.name)

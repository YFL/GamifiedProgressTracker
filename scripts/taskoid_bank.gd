class_name TaskoidBank extends RefCounted

signal project_added(project: Project)
signal project_removed(project: Project)
signal task_added(task: Task)
signal task_removed(task: Task)

var projects: Dictionary
var tasks: Dictionary

func params_from_config(config: Taskoid.Config) -> Result:
  if not config.parent.is_empty() and not projects.has(config.parent):
    return Result.new(null, "Parent with name " + config.parent + " doesn't exist")
  var parent: Project = projects.get(config.parent)
  if parent != null and not parent.can_fit(config.difficulty):
    return Result.new(null, "Parent " + config.parent + " can't fit task " + config.name)
  return Result.new(Taskoid.Params.new(config.name, config.description, config.difficulty,
    parent, config.has_deadline, config.deadline))

func create_project(config: Taskoid.Config) -> Result:
  if projects.has(config.name):
    return Result.new(null, "Project with name " + config.name + " already exists")
  var res := params_from_config(config)
  if res.result == null:
    return res
  var project := Project.new(res.result)
  projects[config.name] = project
  print("Project \"" + str(project) + "\" added")
  project_added.emit(project)
  return Result.new(project)

func create_task(config: Taskoid.Config) -> Result:
  if tasks.has(config.name):
    return Result.new(null, "Task with name" + config.anem + " already exists")
  var res := params_from_config(config)
  if res.result == null:
    return res
  var task := Task.new(res.result)
  tasks[config.name] = task
  print("Task \"" + str(task) + "\" added")
  task_added.emit(task)
  return Result.new(task)

func get_project(project_name: String) -> Project:
  return projects.get(project_name)

func get_task(task_name: String) -> Task:
  return tasks.get(task_name)

func get_projects() -> Array[Project]:
  var projects: Array[Project]
  for key: String in self.projects:
    projects.append(self.projects[key])
  return projects

func get_tasks() -> Array[Task]:
  var tasks: Array[Task]
  for key: String in self.tasks:
    tasks.append(self.tasks[key])
  return tasks

func has_project_name(project_name: String) -> bool:
  return projects.has(project_name)

func has_task_name(task_name: String) -> bool:
  return tasks.has(task_name)

func has_project(project: Project) -> bool:
  return has_project_name(project.name)

func has_task(task: Task) -> bool:
  return has_task_name(task.name)

func remove_project_name(project_name: String) -> void:
  var project: Project = projects.get(project_name)
  if project == null:
    return
  projects.erase(project_name)
  project_removed.emit(project)

func remove_task_name(task_name: String) -> void:
  var task: Task = projects.get(task_name)
  if task == null:
    return
  tasks.erase(task)
  task_removed.emit(task)

func remove_project(project: Project) -> void:
  remove_project_name(project.name)

func remove_task(task: Task) -> void:
  remove_task_name(task.name)

func reset() -> void:
  projects.clear()
  tasks.clear()

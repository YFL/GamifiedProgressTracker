class_name ProjectBank extends RefCounted

signal project_added(project: Project)
signal project_removed(project: Project)

var projects: Dictionary

func create(name: String, description: String, parent: Project, duration: int) -> Project:
  if projects.has(name):
    return null
  var project := Project.new(name, description, parent, duration)
  projects[name] = project
  print("Project \"" + str(project) + "\" added")
  project_added.emit(project)
  return project

func get_project(project_name: String) -> Project:
  return projects.get(project_name)

func get_projects() -> Array[Project]:
  var projects: Array[Project]
  for key: String in self.projects:
    projects.append(self.projects[key])
  return projects

func has(project_name: String) -> bool:
  return projects.has(project_name)

func has_task(task: Task) -> bool:
  return has(task.name)

func remove(project_name: String) -> void:
  var project: Project = projects.get(project_name)
  if project == null:
    return
  projects.erase(project_name)
  project_removed.emit(project)

func remove_project(project: Project) -> void:
  remove(project.name)
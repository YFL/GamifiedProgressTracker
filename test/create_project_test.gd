extends GdUnitTestSuite

const project_names: Array[String] = ["a", "b", "c", "d"]
const difficulties: Array[int] = [Difficulty.Modest, Difficulty.NoteWorthy, Difficulty.Commendable, Difficulty.Glorious]
var projects: Array[Project]

func before_test() -> void:
  projects.clear()
  var params := Taskoid.Params.new(project_names[0], project_names[0], Difficulty.Glorious, null, false, "")
  projects.append(Project.new(params))
  # 0 is Easy 2 is Hard, if it's not, change the loop
  for i: int in range (1, 3):
    params.name = project_names[i]
    params.description = project_names[i]
    params.parent = projects[i - 1]
    params.difficulty = difficulties[difficulties.size() - 1 - i]
    projects.append(Project.new(params))

func test_create_invalid_project() -> void:
  # Difficulty.Easy is not allowed for projects
  var params := Taskoid.Params.new(project_names[0], project_names[0], difficulties[0], null, false, "")
  var project := Project.new(params)
  assert_str(project.name).is_empty()
  assert_int(project.difficulty).is_equal(Difficulty.Invalid)

func test_create_parentless_project() -> void:
  assert_str(projects[0].name).is_equal(project_names[0])
  assert_object(projects[0].parent).is_null()
  assert_int(projects[0].difficulty).is_equal(Difficulty.Glorious)

func test_create_project():
  assert_array(projects).has_size(3)
  for i: int in range(projects.size() - 1, 0, -1):
    var difficulty_idx := difficulties.size() - 1 - i
    var parent := projects[i - 1]
    var project := projects[i]
    assert_object(project.parent).is_equal(parent)
    assert_array(parent.children).contains([project]).has_size(1)
    assert_int(project.children_difficulty).is_equal(0)
    assert_str(project.name).is_equal(project_names[i])
    assert_int(project.difficulty).is_equal(difficulties[difficulty_idx])

func test_add_task_to_child() -> void:
  for i: int in range(0, projects.size()):
    var params := Taskoid.Params.new(project_names[i], project_names[i], difficulties[difficulties.size() - 2 - i], projects[i], false, "")
    Task.new(params)
  var medium_project := projects[2]
  assert_int(medium_project.children_difficulty).is_equal(Difficulty.Modest)
  assert_array(medium_project.children).has_size(1)
  var hard_project := projects[1]
  assert_int(hard_project.children_difficulty).is_equal(Difficulty.Modest + Difficulty.NoteWorthy)
  assert_array(hard_project.children).has_size(2)
  var gigantic_project := projects[0]
  assert_int(gigantic_project.children_difficulty).is_equal(Difficulty.Modest + Difficulty.NoteWorthy + Difficulty.Commendable)
  assert_array(gigantic_project.children).has_size(2)


func test_child_exceeding_capacity() -> void:
  var params := Taskoid.Params.new("parent", "", Difficulty.NoteWorthy, null, false, "")
  var parent_project := Project.new(params)
  params.name = "child"
  params.parent = parent_project
  var child_project := Project.new(params)
  params.parent = child_project
  var child_task := Task.new(params)
  assert_int(parent_project.children_difficulty).is_equal(child_task.difficulty)
  params.name = "parent"
  params.parent = parent_project
  var parent_task := Task.new(params)
  assert_int(child_project.children_difficulty).is_equal(child_task.difficulty)
  assert_int(parent_project.children_difficulty).is_equal(child_task.difficulty)
  assert_array(parent_project.children).not_contains([parent_task]).has_size(1)

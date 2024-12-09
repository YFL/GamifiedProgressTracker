extends GdUnitTestSuite

const project_names: Array[String] = ["a", "b", "c", "d"]
const difficulties: Array[int] = [Difficulty.Easy, Difficulty.Medium, Difficulty.Hard, Difficulty.Gigantic]
var projects: Array[Project]

func before_test() -> void:
  projects.clear()
  projects.append(Project.new(project_names[0], project_names[0], null, Difficulty.Gigantic))
  # 0 is Easy 2 is Hard, if it's not, change the loop
  for i: int in range (1, 3):
    projects.append(Project.new(project_names[i], project_names[i], projects[i - 1], difficulties[difficulties.size() - 1 - i]))

func test_create_invalid_project() -> void:
  # Difficulty.Easy is not allowed for projects
  var project := Project.new(project_names[0], project_names[0], null, difficulties[0])
  assert_str(project.name).is_empty()
  assert_int(project.capacity).is_equal(Difficulty.Invalid)

func test_create_parentless_project() -> void:
  assert_str(projects[0].name).is_equal(project_names[0])
  assert_object(projects[0].parent).is_null()
  assert_int(projects[0].capacity).is_equal(Difficulty.Gigantic)

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
    assert_int(project.capacity).is_equal(difficulties[difficulty_idx])

func test_add_task_to_child() -> void:
  for i: int in range(0, projects.size()):
    Task.new(project_names[i], project_names[i], projects[i], false, difficulties[difficulties.size() - 2 - i])
  var medium_project := projects[2]
  assert_int(medium_project.children_difficulty).is_equal(Difficulty.Easy)
  assert_array(medium_project.children).has_size(1)
  var hard_project := projects[1]
  assert_int(hard_project.children_difficulty).is_equal(Difficulty.Easy + Difficulty.Medium)
  assert_array(hard_project.children).has_size(2)
  var gigantic_project := projects[0]
  assert_int(gigantic_project.children_difficulty).is_equal(Difficulty.Easy + Difficulty.Medium + Difficulty.Hard)
  assert_array(gigantic_project.children).has_size(2)


func test_child_exceeding_capacity() -> void:
  var parent_project := Project.new("parent", "", null, Difficulty.Medium)
  var child_project := Project.new("child", "", parent_project, Difficulty.Medium)
  var child_task := Task.new("child", "", child_project, false, Difficulty.Medium)
  assert_int(parent_project.children_difficulty).is_equal(child_task.difficulty)
  var parent_task := Task.new("parent", "", parent_project, false, Difficulty.Medium)
  assert_int(child_project.children_difficulty).is_equal(child_task.difficulty)
  assert_int(parent_project.children_difficulty).is_equal(child_task.difficulty)
  assert_array(parent_project.children).not_contains([parent_task]).has_size(1)
extends GdUnitTestSuite

var parent_project: Project = null
var project: Project = null

func before() -> void:
  parent_project = Project.new("Test", "TestDescription", null, Difficulty.Majestic)

func test_task_persistence() -> void:
  var task := Task.new("test", "testDescription", null, Difficulty.Modest)
  var json := JSON.stringify(task.to_dict())
  var dict: Dictionary = JSON.parse_string(json)
  assert_dict(dict).contains_keys([
    Task.name_key,
    Task.description_key,
    Task.parent_name_key,
    Task.completed_key,
    Task.difficulty_key])
  assert_dict(dict).contains_key_value(Task.name_key, task.name)
  assert_dict(dict).contains_key_value(Task.description_key, task.description)
  assert_dict(dict).contains_key_value(Task.parent_name_key, "")
  assert_dict(dict).contains_key_value(Task.completed_key, task.completed)
  # Difficulty has to be converted to float, because all numbers are converted to float in
  # JSON.stringify
  assert_dict(dict).contains_key_value(Task.difficulty_key, float(task.difficulty))

  task = Task.new("test2", "testDescription2", parent_project, Difficulty.Modest)
  task.complete()
  json = JSON.stringify(task.to_dict())
  dict = JSON.parse_string(json)
  assert_dict(dict).contains_keys([
    Task.name_key,
    Task.description_key,
    Task.parent_name_key,
    Task.completed_key,
    Task.difficulty_key])
  assert_dict(dict).contains_key_value(Task.name_key, task.name)
  assert_dict(dict).contains_key_value(Task.description_key, task.description)
  assert_dict(dict).contains_key_value(Task.parent_name_key, parent_project.name)
  assert_dict(dict).contains_key_value(Task.completed_key, task.completed)
  # Difficulty has to be converted to float, because all numbers are converted to float in
  # JSON.stringify
  assert_dict(dict).contains_key_value(Task.difficulty_key, float(task.difficulty))
  
  var test_task := Task.new(dict[Task.name_key], dict[Task.description_key], parent_project, int(dict[Task.difficulty_key]))
  if dict[Task.completed_key]:
    test_task.complete()
  assert_str(test_task.name).is_equal(task.name)
  assert_str(test_task.description).is_equal(task.description)
  assert_str(test_task.parent.name).is_equal(task.parent.name)
  assert_bool(test_task.completed).is_equal(task.completed)
  assert_int(test_task.difficulty).is_equal(task.difficulty)

func test_project_persistence() -> void:
  var project := Project.new("test", "testDescription", null, Difficulty.Majestic)
  var json := JSON.stringify(project.to_dict())
  var dict: Dictionary = JSON.parse_string(json)
  assert_dict(dict).contains_keys([
    Project.name_key,
    Project.description_key,
    Project.capacity_key,
    Project.parent_name_key
  ])
  assert_dict(dict).contains_key_value(Project.name_key, project.name)
  assert_dict(dict).contains_key_value(Project.description_key, project.description)
  # Capacity has to be converted to float, because all numbers are converted to float in
  # JSON.stringify
  assert_dict(dict).contains_key_value(Project.capacity_key, float(project.capacity))
  assert_dict(dict).contains_key_value(Project.parent_name_key, "")

  project = Project.new("test2", "testDescription2", parent_project, Difficulty.NoteWorthy)
  json = JSON.stringify(project.to_dict())
  dict = JSON.parse_string(json)
  assert_dict(dict).contains_keys([
    Project.name_key,
    Project.description_key,
    Project.capacity_key,
    Project.parent_name_key
  ])
  assert_dict(dict).contains_key_value(Project.name_key, project.name)
  assert_dict(dict).contains_key_value(Project.description_key, project.description)
  # Capacity has to be converted to float, because all numbers are converted to float in
  # JSON.stringify
  assert_dict(dict).contains_key_value(Project.capacity_key, float(project.capacity))
  assert_dict(dict).contains_key_value(Project.parent_name_key, parent_project.name)
  
  var test_project := Project.new(dict[Project.name_key], dict[Project.description_key], parent_project, int(dict[Project.capacity_key]))
  assert_str(test_project.name).is_equal(project.name)
  assert_str(test_project.description).is_equal(project.description)
  assert_int(test_project.capacity).is_equal(project.capacity)
  assert_str(test_project.parent.name).is_equal(project.parent.name)

func test_reward_persistence() -> void:
  var reward := Reward.new("test", Difficulty.Modest, Reward.RewardTier.Common)
  var json := JSON.stringify(reward.to_dict())
  var dict: Dictionary = JSON.parse_string(json)
  assert_dict(dict).contains_keys([Reward.name_key, Reward.tier_key, Reward.difficulty_key])
  assert_dict(dict).contains_key_value(Reward.name_key, reward.name)
  # Difficulty has to be converted to float, because all numbers are converted to float in
  # JSON.stringify
  assert_dict(dict).contains_key_value(Reward.difficulty_key, float(reward.difficulty))
  # Tier has to be converted to float, because all numbers are converted to float in
  # JSON.stringify
  assert_dict(dict).contains_key_value(Reward.tier_key, float(reward.tier))
  var test_reward := Reward.new(dict[Reward.name_key], int(dict[Reward.difficulty_key]), int(dict[Reward.tier_key]))
  assert_str(test_reward.name).is_equal(reward.name)
  assert_int(test_reward.difficulty).is_equal(reward.difficulty)
  assert_int(test_reward.tier).is_equal(reward.tier)
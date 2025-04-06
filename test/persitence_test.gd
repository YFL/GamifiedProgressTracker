extends GdUnitTestSuite

var parent_project: Project = null
var project: Project = null

func before() -> void:
  var params := Taskoid.Params.new("Test", "TestDescription", Difficulty.Majestic, null, false, "", null)
  parent_project = Project.new(params)

func test_task_persistence() -> void:
  var params := Taskoid.Params.new("test", "testDescription", Difficulty.Modest, null, false, "", null)
  var task := Task.new(params)
  var json := JSON.stringify(task.config().to_dict())
  var dict: Dictionary = JSON.parse_string(json)
  assert_dict(dict).contains_keys([
    Taskoid.Config.name_key,
    Taskoid.Config.description_key,
    Taskoid.Config.parent_name_key,
    Taskoid.Config.completed_key,
    Taskoid.Config.difficulty_key])
  assert_dict(dict).contains_key_value(Task.Config.name_key, task.name)
  assert_dict(dict).contains_key_value(Task.Config.description_key, task.description)
  assert_dict(dict).contains_key_value(Task.Config.parent_name_key, "")
  assert_dict(dict).contains_key_value(Task.Config.completed_key, task.completed)
  # Difficulty has to be converted to float, because all numbers are converted to float in
  # JSON.stringify
  assert_dict(dict).contains_key_value(Task.Config.difficulty_key, float(task.difficulty))

  params.name = "test2"
  params.description = "testDescription2"
  params.parent = parent_project
  task = Task.new(params)
  task.complete()
  json = JSON.stringify(task.config().to_dict())
  dict = JSON.parse_string(json)
  assert_dict(dict).contains_keys([
    Task.Config.name_key,
    Task.Config.description_key,
    Task.Config.parent_name_key,
    Task.Config.completed_key,
    Task.Config.difficulty_key])
  assert_dict(dict).contains_key_value(Task.Config.name_key, task.name)
  assert_dict(dict).contains_key_value(Task.Config.description_key, task.description)
  assert_dict(dict).contains_key_value(Task.Config.parent_name_key, parent_project.name)
  assert_dict(dict).contains_key_value(Task.Config.completed_key, task.completed)
  # Difficulty has to be converted to float, because all numbers are converted to float in
  # JSON.stringify
  assert_dict(dict).contains_key_value(Task.Config.difficulty_key, float(task.difficulty))
  
  params.name = dict[Task.Config.name_key]
  params.description = dict[Task.Config.description_key]
  params.difficulty = int(dict[Task.Config.difficulty_key])
  var test_task := Task.new(params)
  if dict[Task.Config.completed_key]:
    test_task.complete()
  assert_str(test_task.name).is_equal(task.name)
  assert_str(test_task.description).is_equal(task.description)
  assert_str(test_task.parent.name).is_equal(task.parent.name)
  assert_bool(test_task.completed).is_equal(task.completed)
  assert_int(test_task.difficulty).is_equal(task.difficulty)

func test_project_persistence() -> void:
  var params := Taskoid.Params.new("test", "testDescription", Difficulty.Majestic, null, false, "", null)
  var project := Project.new(params)
  var json := JSON.stringify(project.config().to_dict())
  var dict: Dictionary = JSON.parse_string(json)
  assert_dict(dict).contains_keys([
    Taskoid.Config.name_key,
    Taskoid.Config.description_key,
    Taskoid.Config.difficulty_key,
    Taskoid.Config.parent_name_key
  ])
  assert_dict(dict).contains_key_value(Taskoid.Config.name_key, project.name)
  assert_dict(dict).contains_key_value(Taskoid.Config.description_key, project.description)
  # Capacity has to be converted to float, because all numbers are converted to float in
  # JSON.stringify
  assert_dict(dict).contains_key_value(Taskoid.Config.difficulty_key, float(project.difficulty))
  assert_dict(dict).contains_key_value(Taskoid.Config.parent_name_key, "")

  params.name = "test2"
  params.description = "testDescription2"
  params.parent = parent_project
  params.difficulty = Difficulty.NoteWorthy
  project = Project.new(params)
  json = JSON.stringify(project.config().to_dict())
  dict = JSON.parse_string(json)
  assert_dict(dict).contains_keys([
    Taskoid.Config.name_key,
    Taskoid.Config.description_key,
    Taskoid.Config.difficulty_key,
    Taskoid.Config.parent_name_key
  ])
  assert_dict(dict).contains_key_value(Taskoid.Config.name_key, project.name)
  assert_dict(dict).contains_key_value(Taskoid.Config.description_key, project.description)
  # Capacity has to be converted to float, because all numbers are converted to float in
  # JSON.stringify
  assert_dict(dict).contains_key_value(Taskoid.Config.difficulty_key, float(project.difficulty))
  assert_dict(dict).contains_key_value(Taskoid.Config.parent_name_key, parent_project.name)
  
  params = Taskoid.Params.new(dict[Taskoid.Config.name_key], dict[Taskoid.Config.description_key], int(dict[Taskoid.Config.difficulty_key]), parent_project, false, "", null)
  var test_project := Project.new(params)
  assert_str(test_project.name).is_equal(project.name)
  assert_str(test_project.description).is_equal(project.description)
  assert_int(test_project.difficulty).is_equal(project.difficulty)
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
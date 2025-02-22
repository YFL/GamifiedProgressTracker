extends GdUnitTestSuite

var task_bank: TaskBank = TaskBank.new()
var task_names: Array[String] = ["a", "b", "c", "d"]
const easy := Difficulty.Modest

func before_test() -> void:
  for task_name: String in task_names:
    task_bank.remove(task_name)
    task_bank.create(task_name, task_name, null, easy)

func test_task_create_and_get() -> void:
  for task_name: String in task_names:
    var task := task_bank.get_task(task_name)
    assert_bool(task != null).is_true()
    assert_str(task.name).is_equal(task_name)
    assert_object(task.parent).is_null()
    assert_int(task.difficulty).is_equal(easy)

func test_remove_and_remove_task() -> void:
  task_bank.remove(task_names[0])
  assert_bool(task_bank.has(task_names[0])).is_false()
  var task := task_bank.get_task(task_names[1])
  task_bank.remove_task(task)
  assert_bool(task_bank.has(task_names[1])).is_false()
  assert_bool(task_bank.has_task(task)).is_false()

func test_has_and_has_task() -> void:
  assert_bool(task_bank.has(task_names[0])).is_true()
  var task := task_bank.get_task(task_names[0])
  assert_bool(task_bank.has_task(task)).is_true()
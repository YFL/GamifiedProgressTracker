extends GdUnitTestSuite

const easy = Task.TaskDifficulty.Easy # 1
const medium = Task.TaskDifficulty.Medium # 10
const hard = Task.TaskDifficulty.Hard # 20
const gigantic = Task.TaskDifficulty.Gigantic # 60

func test_combined_difficulties() -> void:
  assert_int(Task.categorize_difficulty(9 * easy)).is_equal(easy)
  assert_int(Task.categorize_difficulty(10 * easy)).is_equal(medium)
  assert_int(Task.categorize_difficulty(medium + 9 * easy)).is_equal(medium)
  assert_int(Task.categorize_difficulty(medium + medium)).is_equal(hard)
  assert_int(Task.categorize_difficulty(hard + 39 * easy)).is_equal(hard)
  assert_int(Task.categorize_difficulty(hard + medium + 29 * easy)).is_equal(hard)
  assert_int(Task.categorize_difficulty(hard + 2 * medium + 19 * easy)).is_equal(hard)
  assert_int(Task.categorize_difficulty(hard + 3 * medium + 9 * easy)).is_equal(hard)
  assert_int(Task.categorize_difficulty(2 * hard + 19 * easy)).is_equal(hard)
  assert_int(Task.categorize_difficulty(2 * hard + medium + 9 * easy)).is_equal(hard)
  assert_int(Task.categorize_difficulty(3 * hard)).is_equal(gigantic)
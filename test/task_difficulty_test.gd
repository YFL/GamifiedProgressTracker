extends GdUnitTestSuite

const easy = Difficulty.Easy # 1
const medium = Difficulty.Medium # 10
const hard = Difficulty.Hard # 20
const gigantic = Difficulty.Gigantic # 60

func test_combined_difficulties() -> void:
  assert_int(Difficulty.categorize_difficulty(9 * easy)).is_equal(easy)
  assert_int(Difficulty.categorize_difficulty(10 * easy)).is_equal(medium)
  assert_int(Difficulty.categorize_difficulty(medium + 9 * easy)).is_equal(medium)
  assert_int(Difficulty.categorize_difficulty(medium + medium)).is_equal(hard)
  assert_int(Difficulty.categorize_difficulty(hard + 39 * easy)).is_equal(hard)
  assert_int(Difficulty.categorize_difficulty(hard + medium + 29 * easy)).is_equal(hard)
  assert_int(Difficulty.categorize_difficulty(hard + 2 * medium + 19 * easy)).is_equal(hard)
  assert_int(Difficulty.categorize_difficulty(hard + 3 * medium + 9 * easy)).is_equal(hard)
  assert_int(Difficulty.categorize_difficulty(2 * hard + 19 * easy)).is_equal(hard)
  assert_int(Difficulty.categorize_difficulty(2 * hard + medium + 9 * easy)).is_equal(hard)
  assert_int(Difficulty.categorize_difficulty(3 * hard)).is_equal(gigantic)
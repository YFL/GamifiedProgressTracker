extends GdUnitTestSuite

const easy = Difficulty.Modest # 10
const medium = Difficulty.NoteWorthy # 60
const hard = Difficulty.Commendable # 480
const gigantic = Difficulty.Glorious # 1440

func test_combined_difficulties() -> void:
  assert_int(Difficulty.categorize_difficulty(5 * easy)).is_equal(easy)
  assert_int(Difficulty.categorize_difficulty(6 * easy)).is_equal(medium)
  assert_int(Difficulty.categorize_difficulty(medium + 6 * easy)).is_equal(medium)
  assert_int(Difficulty.categorize_difficulty(8 * medium)).is_equal(hard)
  # ...
extends GdUnitTestSuite

var reward_bank := RewardBank.new()
var reward_names: Array[String] = ["a", "b", "c", "d"]
const easy := Difficulty.Modest
const medium := Difficulty.NoteWorthy
const hard := Difficulty.Commendable
const gigantic := Difficulty.Glorious
const difficulties: Array[int] = [easy, medium, hard, gigantic]

func before_test() -> void:
  for i: int in reward_names.size():
    reward_bank.remove(reward_names[i])
    reward_bank.create(reward_names[i], difficulties[i], i as Reward.RewardTier)

func test_reward_create_and_get() -> void:
  for i: int in reward_names.size():
    var reward := reward_bank.get_reward(reward_names[i])
    assert_bool(reward != null).is_true()
    assert_str(reward.name).is_equal(reward_names[i])
    assert_int(reward.difficulty).is_equal(difficulties[i])
    assert_int(reward.tier).is_equal(i)

func test_remove_and_remove_reward() -> void:
  reward_bank.remove(reward_names[0])
  assert_bool(reward_bank.has(reward_names[0])).is_false()
  var reward := reward_bank.get_reward(reward_names[1])
  reward_bank.remove_reward(reward)
  assert_bool(reward_bank.has(reward_names[1])).is_false()
  assert_bool(reward_bank.has_reward(reward)).is_false()

func test_has_and_has_reward() -> void:
  assert_bool(reward_bank.has(reward_names[0])).is_true()
  var reward := reward_bank.get_reward(reward_names[0])
  assert_bool(reward_bank.has_reward(reward)).is_true()
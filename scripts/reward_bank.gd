class_name RewardBank extends RefCounted

signal reward_added(reward: Reward)
signal reward_removed(reward: Reward)

var rewards: Dictionary

func create(name: String, difficulty: int, tier: Reward.RewardTier) -> Reward:
  if rewards.has(name):
    return null
  var reward := Reward.new(name, difficulty, tier)
  rewards[name] = reward
  print("Reward \"" + str(reward) + "\" added")
  reward_added.emit(reward)
  return reward

func get_reward(name: String) -> Reward:
  return rewards.get(name)

func get_rewards() -> Array[Reward]:
  var rewards: Array[Reward]
  for key: String in self.rewards:
    rewards.append(self.rewards[key])
  return rewards

func has(name: String) -> bool:
  return rewards.has(name)

func has_reward(reward: Reward) -> bool:
  return has(reward.name)

func remove(name: String) -> void:
  var reward: Reward = rewards.get(name)
  if reward == null:
    return
  rewards.erase(name)
  reward_removed.emit(reward)

func remove_reward(reward: Reward) -> void:
  remove(reward.name)

func reward_for(difficulty: int) -> Reward:
  var possible_rewards: Array[Reward]
  for key: String in rewards:
    var reward: Reward = rewards[key]
    if reward.difficulty == difficulty:
      possible_rewards.append(reward)
  var tier := RandomNumberGenerator.new().randi_range(0, Reward.RewardTier.Count - 1)
  var filtered := possible_rewards.filter(func (reward: Reward): return reward.tier >= tier)
  if filtered.is_empty():
    filtered = possible_rewards
  return filtered.pick_random() if not filtered.is_empty() else null

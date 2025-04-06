class_name RevivingEntity extends Entity

func should_be_drawn() -> bool:
  var dict_from_system := Time.get_date_dict_from_system()
  var date_from_system := Date.from_dict(dict_from_system)
  return date_from_system.result.gte(taskoid.repetition_config.starting_date) and \
    (taskoid.completed or taskoid.deadline.gte(date_from_system.result))

func on_draw() -> void:
  taskoid.prepare_to_be_repeated()
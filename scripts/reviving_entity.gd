class_name RevivingEntity extends Entity

var _has_been_drawn := false

func should_be_drawn() -> bool:
  # Should be draw if:
    # The current date is less then or equal the system date AND
    # The task is NOT completed AND
    # The task is NOT already drawn
  return Date.new(Time.get_date_dict_from_system())\
    .gte(taskoid.repetition_config.current_starting_date) and \
    not taskoid.completed and not _has_been_drawn

func should_be_advanced() -> bool:
  return Date.new(Time.get_date_dict_from_system())\
    .gte(taskoid.repetition_config.next_starting_date)

func on_draw() -> void:
  _has_been_drawn = true

func on_hide() -> void:
  _has_been_drawn = false
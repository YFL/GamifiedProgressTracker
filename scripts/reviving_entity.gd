class_name RevivingEntity extends Entity

# TODO: has to be set to false when the taskoid is "hidden" when it's completed
# TODO: the taskoid has to be "hidden", when completed; hidden might mean, that the tile contains a
# dead entity.
var _has_been_drawn := false

func should_be_drawn() -> bool:
  var dict_from_system := Time.get_date_dict_from_system()
  var date_from_system := Date.new(dict_from_system)
  # Should be draw if:
    # The current date is less then or equal the system date AND
    # The task is NOT completed AND
    # The task is NOT already drawn
  return date_from_system.gte(taskoid.repetition_config.next_starting_date) and \
    not taskoid.completed and not _has_been_drawn

func should_be_advanced() -> bool:
  return Date.new(Time.get_date_dict_from_system())\
    .gte(taskoid.repetition_config.next_starting_date)

func on_draw() -> void:
  _has_been_drawn = true
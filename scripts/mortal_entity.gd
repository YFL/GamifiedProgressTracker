class_name MortalEntity extends Entity

var _should_be_drawn := true

func _init(taskoid: Taskoid) -> void:
  super._init(taskoid)
  _should_be_drawn = not taskoid.completed

func should_be_draw() -> bool:
  return _should_be_drawn

func on_draw() -> void:
  _should_be_drawn = false
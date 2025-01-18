class_name ButtonPanel extends PanelContainer

# Speed of slide in px/s.
@export var speed := 20

@onready var target_position: Vector2i

const shown_pos := Vector2i(0, 0)

# By default the panel is hidden, so we have to make sure it doesn't move
var hidden_pos: Vector2i
var is_ready := false

## Starts sliding the panel either to be shown or to be hidden, depending on the last set target.
func slide() -> void:
  target_position = shown_pos if target_position == hidden_pos else hidden_pos

func _ready() -> void:
  hidden_pos = Vector2i(int(-self.size.x), 0)
  target_position = hidden_pos
  is_ready = true

func _process(delta: float) -> void:
  if not is_ready:
    pass

  if int(position.x) != target_position.x:
    var offset := -(position.x - target_position.x)
    var movement := offset * delta * speed
    position.x += movement
  else:
    position = target_position
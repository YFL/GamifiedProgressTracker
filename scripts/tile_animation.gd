class_name TileAnimation extends RefCounted

var current_frame: int = 0
var fps: float = 7
var frames: int = 4
var switch_time: float = 0
var time_since_last_switch: float = 0
var sprite_coords: Array[Vector2i]

func _init(sprite_coords: Array[Vector2i], fps: float = 7) -> void:
  self.frames = len(sprite_coords)
  self.fps = fps
  self.sprite_coords = sprite_coords
  switch_time = 1/fps
  time_since_last_switch = 0
  current_frame = 0

func animate(delta: float) -> Vector2i:
  if time_since_last_switch + delta >= switch_time:
    time_since_last_switch = 0
    current_frame = current_frame + 1 if current_frame + 1 < frames else 0
  else:
    time_since_last_switch += delta
  return sprite_coords[current_frame]

class_name Character extends CharacterBody2D

signal arrived(target: Vector2)

@onready var animation: AnimatedSprite2D = $Animation

@export var speed := 10

var target: Vector2
var notify := false
var has_target := false

## We use the notify param to emit the arrived signal which is used
## as a task completion signal
## TODO: redo the notify part to something less hacky
func move_to_target(target: Vector2, notify: bool = false) -> void:
  self.target = target
  self.notify = notify
  has_target = true

func _process(delta: float) -> void:
  if not has_target:
    return
  if target.is_equal_approx(position):
    position = target
    has_target = false
    if animation.is_playing():
      animation.stop()
    if notify:
      arrived.emit(target)
      notify = false
    return
  if not animation.is_playing():
    animation.play("walk")
  var distance := target - position
  var direction := distance.normalized()
  var motion := direction * speed * delta
  motion = motion if motion.length_squared() <= distance.length_squared() else distance
  move_and_collide(motion)

class_name Character extends CharacterBody2D

signal arrived(target: Vector2)

@onready var animation: AnimatedSprite2D = $Animation

@export var speed := 10

var target: Vector2
var notify := false
var already_notified := false
var has_target := false

func move_to_target(target: Vector2, notify: bool = false) -> void:
  self.target = target
  self.notify = notify
  already_notified = false
  has_target = true

func _process(delta: float) -> void:
  if not has_target:
    return
  if target.is_equal_approx(position):
    position = target
    has_target = false
    if animation.is_playing():
      animation.stop()
      if notify and not already_notified:
        arrived.emit(target)
        already_notified = true
    return
  if not animation.is_playing():
    animation.play("walk")
  var distance := target - position
  var direction := distance.normalized()
  var motion := direction * speed * delta
  motion = motion if motion.length_squared() <= distance.length_squared() else distance
  move_and_collide(motion)

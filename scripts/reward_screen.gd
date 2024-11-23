class_name RewardScreen extends TextureRect

@onready var close: TextureButton = $Close
@onready var reward: Label = $Reward
@onready var sprinkles: TextureRect = $Sprinkles

func _on_close_pressed() -> void:
	hide()

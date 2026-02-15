extends Node3D

@onready var animated_sprite: AnimatedSprite3D = $AnimatedSprite3D

func _ready() -> void:
	# Connect the signal
	animated_sprite.animation_finished.connect(_on_animation_finished)

func _on_animation_finished():
	queue_free()

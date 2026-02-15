extends Node3D

@onready var label: Label3D = $Label3D
@export var rise_distance: float = 0.2
@export var lifetime: float = 0.6

func _ready() -> void:
	var tween := create_tween()
	var start_pos := position

	
	tween.tween_property(self, "position", start_pos + Vector3(0, rise_distance, 0), lifetime)

	# Fade the label out
	if label:
		tween.parallel().tween_property(label, "modulate:a", 0.0, lifetime)

	# Delete when finished
	tween.finished.connect(queue_free)

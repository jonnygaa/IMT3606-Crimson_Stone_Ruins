extends Area3D


signal generate_new_dungeon()

# Signal triggered when something enters the area of the collision shape.
func _on_body_entered(body: Node3D) -> void:
	# Makes sure it's the player before signaling a new dungeon generation.
	if body.is_in_group("player"):
		emit_signal("generate_new_dungeon")

extends Area3D

# Signal triggered when something enters the area of the collision shape.
func _on_body_entered(body: Node3D) -> void:
	# Makes sure it's the player before signaling a new dungeon generation.
	if body.is_in_group("player"):
		PlayerInventory.empty_inventory()
		PlayerHealth.reset_health()
		SceneManager.change_scene("res://scenes/ui/main_menu.tscn")

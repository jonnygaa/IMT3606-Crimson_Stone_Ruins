extends Area3D

@onready var infoArea:Control = get_tree().get_root().find_child("Tutorial_info", true, false)

# Signal triggered when something enters the area of the collision shape.
func _on_body_entered(body: Node3D) -> void:
	# Makes sure it's the player before signaling a new dungeon generation.
	if body.is_in_group("player"):
		if infoArea:
			var tutorial_label := infoArea.get_node_or_null("TutorialInfo")
			if tutorial_label:
				tutorial_label.text = "Get to ladder to finnish dungeon level"
			else:
				print("Label 'TutorialInfo' not found inside 'Tutorial_info'!")
		else:
			print("infoArea node not found!")

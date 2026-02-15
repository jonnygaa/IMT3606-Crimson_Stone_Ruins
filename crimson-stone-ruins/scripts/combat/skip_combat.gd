extends Node

func _on_pressed() -> void:
	CombatManager.end_combat_clean_up()
	
	# Go back to previous scene which should be the dungeon
	SceneManager.pop_scene()
	
	# Makes the cursor back to captured after the combat
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

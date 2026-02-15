extends Node

var scene_stack: Array[Node] = []

func change_scene(scene_path: String):
	# Remove current scene
	var current = get_tree().current_scene
	if current:
		current.queue_free()

	# Load new scene
	var new_scene = load(scene_path).instantiate()
	get_tree().root.add_child(new_scene)
	get_tree().current_scene = new_scene

func push_scene(new_scene_path: String):
	# Save current scene in the stack
	var current = get_tree().current_scene
	if current:
		scene_stack.push_back(current)
		current.get_parent().remove_child(current)
	
	# Load new scene
	var new_scene = load(new_scene_path).instantiate()
	get_tree().root.add_child(new_scene)
	get_tree().current_scene = new_scene

func pop_scene():
	# Remove current scene
	var current = get_tree().current_scene
	if current:
		current.queue_free()

	# Restore previous scene from the stack
	if scene_stack.size() > 0:
		var prev = scene_stack.pop_back()
		get_tree().root.add_child(prev)
		get_tree().current_scene = prev

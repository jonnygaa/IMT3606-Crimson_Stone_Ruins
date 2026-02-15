extends CharacterBody3D


@onready var movement: Node = $Movement

func _ready() -> void:
	# Hides the cursor into the window
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _physics_process(delta: float) -> void:
	movement.handle_movement(self, delta)

# Handles the show/hide of the cursor in the game window
func _input(event: InputEvent) -> void:
	# # Toggle mouse capture with Esc
	# if event.is_action_pressed("escape"): # Esc by default
	# 	if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
	# 		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	# 	else:
	# 		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

	# if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
	# 	if Input.get_mouse_mode() == Input.MOUSE_MODE_VISIBLE:
	# 		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	pass

# Sets a new position for the player and updates the camera position accordingly
func set_new_position(pos: Vector3) -> void:
	global_position = pos
	movement.set_camera_position(pos)

func save() -> Dictionary:
	var save_dict = {
		"filename" : get_scene_file_path(),
		"parent" : get_parent().get_path(),
		"name" : name,
		"pos_x" : position.x, # Vector2 is not supported by JSON
		"pos_y" : position.y,
		"pos_z" : position.z,
		"rot_x" : rotation.x,
		"rot_y" : rotation.y,
		"rot_z" : rotation.z,
	}
	return save_dict

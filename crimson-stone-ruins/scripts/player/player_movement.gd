extends Node


enum MovementTypes{
	FORWARD,
	BACKWARD,
	SIDE
}

const SPEED_WALK = 2.0
const SPEED_RUN = 3.0
const JUMP_VELOCITY = 4.5
const CAMERA_OFFSET_WALK = 0.1
const CAMERA_OFFSET_RUN = 0.7

var _current_speed = SPEED_WALK
var _current_camera_offset = Vector2(0.0, 0.0)
var _last_movement_type = MovementTypes.FORWARD

@onready var animated_sprite: AnimatedSprite3D = $"../AnimatedSprite3D"
@onready var camera_controller: Node3D = $"../CameraController"
@onready var camera: Camera3D = $"../CameraController/CameraTarget/Camera3D"

func handle_movement(player: CharacterBody3D, delta: float) -> void:
	# Add the gravity
	# We're not really using physic, but if we have ramps or small steps, we might need this
	if not player.is_on_floor():
		player.velocity += player.get_gravity() * delta
#
	## Handle jump
	## Leaving it here in case of debug purposes
	#if Input.is_action_just_pressed("jump") and player.is_on_floor():
		#player.velocity.y = JUMP_VELOCITY
	
	# Hanlde run
	if Input.is_action_pressed("run"):
		_current_speed = SPEED_RUN
	else:
		_current_speed = SPEED_WALK

	# Get the input direction and handle the movement/deceleration.
	var input_dir := Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
	
	if input_dir != Vector2.ZERO:
		# Get flat camera direction to avoid vertical tilt
		var camera_forward = camera.global_transform.basis.x
		var camera_right = camera.global_transform.basis.z
		
		camera_forward.y = 0
		camera_right.y = 0
		camera_forward = camera_forward.normalized()
		camera_right = camera_right.normalized()
		
		# Combine input with camera direction
		var direction = (camera_forward * input_dir.x + camera_right * -input_dir.y).normalized()
		
		# Makes the check on the input_dir vector since x and z (y for the vector) might be swapped with the camera orientation
		if input_dir.y < 0:
			animated_sprite.play("walk_back")
			_last_movement_type = MovementTypes.BACKWARD
			
			_current_camera_offset.y = -CAMERA_OFFSET_WALK
		elif input_dir.y > 0:
			animated_sprite.play("walk_front")
			_last_movement_type = MovementTypes.FORWARD
			
			_current_camera_offset.y = CAMERA_OFFSET_WALK
		else:
			_current_camera_offset.y = 0.0
			
		if input_dir.x < 0:
			animated_sprite.flip_h = true
			animated_sprite.play("walk_side")
			_last_movement_type = MovementTypes.SIDE
			
			_current_camera_offset.x = -CAMERA_OFFSET_WALK
		elif input_dir.x > 0:
			animated_sprite.flip_h = false
			animated_sprite.play("walk_side")
			_last_movement_type = MovementTypes.SIDE
			
			_current_camera_offset.x = CAMERA_OFFSET_WALK
		else:
			_current_camera_offset.x = 0.0
	
		player.velocity.x = direction.x * _current_speed
		player.velocity.z = direction.z * _current_speed
	else:
		# Depending on the last movement we set the idle animation
		match _last_movement_type:
			MovementTypes.FORWARD:
				animated_sprite.play("idle_front")
			MovementTypes.BACKWARD:
				animated_sprite.play("idle_back")
			MovementTypes.SIDE:
				animated_sprite.play("idle_side")

		# Resets offset vector for camera when idle
		_current_camera_offset = Vector2(0.0, 0.0)
				
		player.velocity.x = move_toward(player.velocity.x, 0, _current_speed)
		player.velocity.z = move_toward(player.velocity.z, 0, _current_speed)

	player.move_and_slide()

	# Apply camera offset and makes the camera lerps toward it
	var camera_new_position = Vector3(
		player.position.x + _current_camera_offset.x,
		player.position.y,
		player.position.z + _current_camera_offset.y,
	)
	
	camera_controller.position = lerp(camera_controller.position, camera_new_position, 0.1)

# Allows camera to be moved directly to a position without lerp
func set_camera_position(pos: Vector3) -> void:
	camera_controller.global_position = pos

extends Camera3D

@export var acceleration = 25.0
@export var moveSpeed = 10.0
@export var mouseSpeed = 300.0

var velocoty = Vector3.ZERO
var lookAngles = Vector2.ZERO

func _process(delta: float) -> void:
	lookAngles.y = clamp(lookAngles.y, PI / -2, PI / 2)
	set_rotation(Vector3(lookAngles.y, lookAngles.x, 0))
	var direction = updateDirection()
	if direction.length_squared() > 0:
		velocoty += direction * acceleration * delta
	if velocoty.length() > moveSpeed:
		velocoty = velocoty.normalized() * moveSpeed
		
	translate(velocoty * delta)
	pass
	
func _input(event: InputEvent) -> void:
	# Mouse rotation (only if captured)
	if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		lookAngles -= event.relative / mouseSpeed

func updateDirection()->Vector3:
	var dir = Vector3()
	
	if Input.is_action_pressed("move_forward"):
		dir += Vector3.FORWARD
	if Input.is_action_pressed("move_backward"):
		dir += Vector3.BACK
	if Input.is_action_pressed("move_left"):
		dir += Vector3.LEFT
	if Input.is_action_pressed("move_right"):
		dir += Vector3.RIGHT
	if Input.is_action_pressed("move_up"):
		dir += Vector3.UP
	if Input.is_action_pressed("move_down"):
		dir += Vector3.DOWN
	if dir == Vector3.ZERO:
		velocoty = Vector3.ZERO
	
	return dir.normalized()

extends CharacterBody3D

@export var speed = 4

var room_in: int
var room_inP: int

# Errors are given here because the roombox is not on the same layer in the test scene and the game scene.
var player
var roomboxP

@onready var animator: AnimatedSprite3D = $Pivot

@onready var roombox = $Roombox

var chase:bool = false

func _ready() -> void:
	var player_node = get_tree().get_nodes_in_group("player")
	# Since player is only instanciated after the dungeon, it's non existant yet when the ennemy is ready.
	if player_node.size() > 0:
		player = player_node[0]
		roomboxP = player.get_node("./Roombox")


func _physics_process(delta):

	if chase:

		var direction = global_position.direction_to(player.global_position).normalized()
		velocity = direction * speed
		
		# Flip the sprite horizontaly for the enemy to face the player
		# Convert player world position into this node's local coordinates:
		var local_pos : Vector3 = to_local(player.global_position)
		const DEADZONE := 0.05
		if local_pos.x > DEADZONE:
			animator.flip_h = true
		elif local_pos.x < -DEADZONE:
			animator.flip_h = false
	else:
		velocity = Vector3.ZERO
		animator.play("Idle")
			
	move_and_slide()


func _on_roombox_body_entered(body: Node3D) -> void:
	# Makes sure it's the player before switching to combat scene
	if body.is_in_group("player"):
		# Delete the enemy because it should be defeated at the end of the combat scene
		queue_free();

		# Save current scene in the stack and push the combat scene
		SceneManager.push_scene("res://scenes/rooms/combat_tutorial.tscn")

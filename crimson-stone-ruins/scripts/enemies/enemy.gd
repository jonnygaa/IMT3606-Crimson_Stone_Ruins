extends CharacterBody3D

@export var speed = 4
@export var enemy_combat_scene: PackedScene = null

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
			animator.flip_h = false
		elif local_pos.x < -DEADZONE:
			animator.flip_h = true
		
		animator.play("Run")
	else:
		velocity = Vector3.ZERO
		animator.play("Idle")
			
	move_and_slide()


func _on_roombox_body_entered(body: Node3D) -> void:
	# Makes sure it's the player before switching to combat scene
	if body.is_in_group("player"):
		# Delete the enemy because it should be defeated at the end of the combat scene
		queue_free();
		
		# Sets the enemy_combat scene that the combat scene will use
		if not enemy_combat_scene == null:
			CombatManager.current_enemy = enemy_combat_scene
		
		# Save current scene in the stack and push the combat scene
		SceneManager.push_scene("res://scenes/rooms/combat_room_1.tscn")

func save() -> Dictionary:
	var save_dict = {
		"filename" : get_scene_file_path(),
		"parent" : get_parent().get_path(),
		"name" : name,
		"pos_x" : position.x,
		"pos_y" : position.y,
		"pos_z" : position.z,
		"rot_x" : global_rotation.x,
		"rot_y" : global_rotation.y,
		"rot_z" : global_rotation.z,
	}
	return save_dict

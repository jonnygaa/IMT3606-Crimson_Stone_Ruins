extends Node3D



@onready var player_slot: Marker3D = $CSGBox3D/PlayerSlot
@onready var enemy_slots: Array = get_tree().get_nodes_in_group("enemy_slot")

@export var player_sceness: PackedScene
@export var ennemy_sceness: Array[PackedScene]

var player_instance: Node3D
var ennemy_instances: Array[Node3D]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for slot in enemy_slots:
		print(slot.name, " at ", slot.global_position)
	print(player_slot.name, " at ", player_slot.global_position)
		
	set_player(player_sceness)
	set_enemies(ennemy_sceness)
	
	CombatManager.set_player_and_enemies(player_instance, ennemy_instances)
	
	# Hides the cursor into the window
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	
func set_player(player_scene: PackedScene) -> void:
	player_instance = player_scene.instantiate()
	player_instance.position = player_slot.position
	add_child(player_instance)
	pass
	
func set_enemies(enemy_scenes: Array[PackedScene]) -> void:
	for i in enemy_scenes.size():
		print(i)
		var new_ennemy_instance = enemy_scenes[i].instantiate()
		new_ennemy_instance.position = enemy_slots[i].position
		new_ennemy_instance.get_node("AnimatedSprite3D").flip_h = true
		ennemy_instances.append(new_ennemy_instance)
		add_child(new_ennemy_instance)
	pass

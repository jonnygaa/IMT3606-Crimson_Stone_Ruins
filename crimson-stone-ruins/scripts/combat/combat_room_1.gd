extends Node3D

@export var player_slot: Marker3D
@onready var enemy_slots: Array = get_tree().get_nodes_in_group("enemy_slot")
@export var ingredietn_slots_parent:Node3D
@onready var ui = $Combat_UI
@onready var target_inidcator = $TargetIndicator3D

@export var player_sceness: PackedScene

var player_instance: Node3D
var ennemy_instances: Array[Node3D]
var active_ingredient_slots:Array[Marker3D]

#  TurnManager Integration
#var combat_ui: Control
var turn_manager: Node
# END


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for slot in enemy_slots:
		print(slot.name, " at ", slot.global_position)
	print(player_slot.name, " at ", player_slot.global_position)
		
	set_player(player_sceness)
	set_enemies()
	var accessory_bonus = PlayerInventory.accessory[0] if PlayerInventory.accessory != null and PlayerInventory.accessory.size() > 0 else 0
	set_ingredient_slots_used(accessory_bonus + 3)
	ui.ingredient_slots = active_ingredient_slots
	ui.target_cursor = target_inidcator
	
	if name == "CombatRoom1":
		ui.target_cursor.scale = Vector3(.5, .5, .5)
	
	print("Number of active slots: ", ui.ingredient_slots.size())
	CombatManager.set_player_and_enemies(player_instance, ennemy_instances)
	
	# Hides the cursor into the window
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

	#  TurnManager Integration 
	var TurnManagerScene = preload("res://scripts/combat/turn_manager.gd")
	turn_manager = TurnManagerScene.new()
	add_child(turn_manager)

	# Connect UI and Turn Manager
	ui.set_turn_manager(turn_manager)
	turn_manager.setup(player_instance, ennemy_instances, ui)
	# END 
	
	
func set_player(player_scene: PackedScene) -> void:
	player_instance = player_scene.instantiate()
	#player_instance.position = player_slot.position
	player_slot.add_child(player_instance)
	if name == "CombatRoomDebug":
		player_instance.scale = Vector3(3.0, 3.0, 3.0)

	
func set_enemies() -> void:
	var enemy = CombatManager.current_enemy
	var enemy_is_boss = GameManager.level_id == 4
	var enemy_count = 3 if Globals.tutorial_flag else 1 if enemy_is_boss else GameManager.level_id
	for i in min(enemy_slots.size(), enemy_count):
		var new_ennemy_instance = enemy.instantiate()

		new_ennemy_instance.get_node("AnimatedSprite3D").flip_h = true
		ennemy_instances.append(new_ennemy_instance)
		enemy_slots[i].add_child(new_ennemy_instance)
	
	if name == "CombatRoomDebug":
		for slot in enemy_slots:
			slot.scale = Vector3(3.0, 3.0, 3.0)

func set_ingredient_slots_used(number:int):
	var slots = ingredietn_slots_parent.get_children()
	match number:
		3:
			active_ingredient_slots = [slots[0], slots[2], slots[4]]
		4:
			active_ingredient_slots = [slots[0], slots[1], slots[2], slots[4]]
		5:
			active_ingredient_slots = [slots[0], slots[1], slots[2], slots[3], slots[4]]
		6:
			active_ingredient_slots = [slots[0], slots[1], slots[2], slots[3], slots[4], slots[5]]
		
	for slot in active_ingredient_slots:
		slot.visible = true

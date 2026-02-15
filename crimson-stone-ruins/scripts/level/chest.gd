extends Node3D

@onready var animated_sprite: AnimatedSprite3D = $AnimatedSprite3D
@onready var interactable: Area3D = $Interactable
@onready var label: Label3D = $Interactable/Label3D
@onready var equip_accessory = get_tree().get_root().find_child("EquipAccessory", true, false)

var content: Array[Ingredient]

signal accessory_changed(new_accessory)

var rng = RandomNumberGenerator.new()
var new_accessory = null

var element_name = ["Fire", "Lightning", "Water", 
					"Earth", "Wind", "Acid"]
var grade_name = ["", "_uncommon", "_rare", "_mythical"]

func _ready() -> void:
	interactable.interact = _interact_chest
	interactable.make_uninteractable = _make_uninteractable

func get_weighted_grade() -> int:
	var r = randf() * 100.0
	if r < 40.0:
		return 0
	elif r < 70.0:
		return 1
	elif r < 90.0:
		return 2
	else:
		return 3

func _interact_chest() -> void:
	if interactable.is_interactable:
		_pause_game()
		
		_make_uninteractable()
		
		# TODO make content random
		var path = "res://resources/ingredients/"
		for i in range(5):
			var grade = get_weighted_grade()
			var element = rng.randi_range(0, 5)
			var ing = str(grade, element, element_name[element], grade_name[grade])
			var ingredient:Ingredient = load(path+ing+".tres")
			ingredient.on_loaded()
			content.append(ingredient)
		
		var inv_ings: Array[int] = PlayerInventory.get_base_inventory()
		for ing in content:
			print("adding ing: " + ing.name + ", count: " + str(PlayerInventory.QUANTITY_BY_LEVEL[ing.quality]))
			inv_ings[ing.id] += PlayerInventory.QUANTITY_BY_LEVEL[ing.quality]
		PlayerInventory.add_ingredients(inv_ings)
		CombatManager.refresh_player_inventory()
		
		var acc_level = rng.randi_range(1, 3)
		var acc_element = rng.randi_range(0, 5)
		new_accessory = [acc_level, acc_element]
		
		if new_accessory:
			equip_accessory.show_accessory(self, new_accessory)
		else:
			print("NewAccessory node not found!")
		
		new_accessory = [acc_level,acc_element]
		print("New accessory generated:", new_accessory)

func _pause_game() -> void:
	get_tree().paused = true

func _make_uninteractable() -> void:
	interactable.is_interactable = false
	animated_sprite.play("open")
	label.hide()

func save() -> Dictionary:
	var save_dict = {
		"filename" : get_scene_file_path(),
		"parent" : get_parent().get_path(),
		"name" : name,
		"pos_x" : position.x, # Vector2 is not supported by JSON
		"pos_y" : position.y,
		"pos_z" : position.z,
		"rot_x" : global_rotation.x,
		"rot_y" : global_rotation.y,
		"rot_z" : global_rotation.z,
		"interactable" : interactable.is_interactable,
	}
	return save_dict

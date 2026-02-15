extends Control

var level_name = ["String", "Pearls", "CrimsonPearls"]
var element_name = ["FIRE", "LIGHTNING", "WATER", 
					"EARTH", "WIND", "ACID"]
var charm_name = ["Flame", "Lightning", "Teardrop", 
				  "Leaf", "Hawk", "Skull"]

@onready var equip: Button = $Equip
@onready var dont_equip: Button = $DontEquip
@onready var accessory_sprite: Sprite2D = $AccessorySprite
@onready var accessory_label: Label = $AccessoryLabel
@onready var infoArea:Control = get_tree().get_root().find_child("Tutorial_info", true, false)

var chest: Node3D


func _ready() -> void:
	visible = false

func _on_equip_pressed() -> void:
	if not chest.new_accessory:
		return
	
	PlayerInventory.accessory = chest.new_accessory
	
	accessory_label.text = ""
	visible = false
	dont_equip.visible = false
	accessory_sprite.texture = null
	
	accessory_label.position.x = int((1152 - accessory_label.get_minimum_size().x)/2)
	
	# Hides back the cursor after the player selected an option
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
	hide_tutorial()
	_play_game()

func _on_dont_equip_pressed() -> void:
	visible = false
	equip.visible = false
	
	accessory_label.text = ""
	
	accessory_label.position.x = int((1152 - accessory_label.get_minimum_size().x)/2)
	
	accessory_sprite.texture = null
	
	# Hides back the cursor after the player selected an option
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
	hide_tutorial()
	_play_game()

func show_accessory(interacted_chest, new_accessory):
	chest = interacted_chest
	if not new_accessory:
		return
	
	visible = true
	
	var level = new_accessory[0]
	var accessoryElement = new_accessory[1]

	var path = "res://assets/accessories/Singles/%d%d_%s_%s.png" % [
		level,
		accessoryElement,
		level_name[level-1],
		charm_name[accessoryElement]
	]
	
	accessory_sprite.texture = load(path)
	
	equip.visible = true
	dont_equip.visible = true
	
	accessory_label.text = str("+", level ," ing per turn\n",
					element_name[accessoryElement], " resistance")
	
	accessory_label.position.x = int((1152- accessory_label.get_minimum_size().x)/2)

	# Shows the cursor to be able to click the buttons
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func _play_game() -> void:
	get_tree().paused = false

func hide_tutorial() -> void:
	if infoArea:
		var tutorial_label := infoArea.get_node_or_null("TutorialInfo")
		if tutorial_label:
			infoArea.hide_acc()
		else:
			print("Label 'TutorialInfo' not found inside 'Tutorial_info'!")
	else:
		print("infoArea node not found!")

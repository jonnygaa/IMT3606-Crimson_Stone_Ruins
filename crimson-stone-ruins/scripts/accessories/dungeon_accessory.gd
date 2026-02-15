extends Sprite2D

@onready var equip:Button = $"../Equip"

var level_name = ["String", "Pearls", "CrimsonPearls"]
var element_name = ["FIRE", "LIGHTNING", "WATER", 
					"EARTH", "WIND", "ACID"]
var charm_name = ["Flame", "Lightning", "Teardrop", 
				  "Leaf", "Hawk", "Skull"]

func _ready():
	print("Accessory UI ready, connecting signal...")
	if not PlayerInventory.is_connected("accessory_changed", set_accessory):
		PlayerInventory.connect("accessory_changed", set_accessory)

func set_accessory():
	var path: String
	
	if PlayerInventory.accessory:
		var level = PlayerInventory.accessory[0]
		var accessoryElement = PlayerInventory.accessory[1]

		path = "res://assets/accessories/Singles/%d%d_%s_%s.png" % [
			level,
			accessoryElement,
			level_name[level-1],
			charm_name[accessoryElement]
		]
		
	print("🖌️ UI updating with:", path)
	texture = load(path)

extends Resource
class_name Ingredient

enum Quality{
	COMMON,
	UNCOMMON,
	RARE,
	MYTHICAL
}

const Elements = preload("res://scripts/element/elements_enum.gd")

@export var id: int # Automaticly set at the start of the program
@export var spirte:PackedScene
@export var name = ""
@export var quality:Quality
@export var element:Elements.Element
@export var icon: Texture2D
var multiplier:float

func on_loaded():
	match quality:
		Quality.COMMON: 
			multiplier = 1.0
		Quality.UNCOMMON: 
			multiplier = 1.25
		Quality.RARE: 
			multiplier = 1.5
		Quality.MYTHICAL: 
			multiplier = 2.0

	
func debug_ingredient_info():
	print("Ingredient ", name, " has quality: ", quality, " and mutliplier: ", multiplier, " and element: ", element)

extends Node
class_name Resistance

@onready var elements = preload("res://scripts/element/elements_enum.gd")

@export var fire_res_multi = 1.0
@export var lighting_res_multi = 1.0
@export var water_res_multi = 1.0
@export var earth_res_multi = 1.0
@export var wind_res_multi = 1.0
@export var acid_res_multi = 1.0

var resistance: Dictionary = {}
var element_name = ["FIRE", "LIGHTNING", "WATER", 
					"EARTH", "WIND", "ACID"]

func init_resistances(is_player:bool):
	print("Called by player: ", is_player)
	
	var value # Value for the resitance multiplier
	for element in elements.Element.values():
		value = 1.0
		#Check for player resistance
		if(is_player && PlayerInventory._accessory && element == PlayerInventory.accessory[1]):
			value = 0.5
		else:
			match elements.Element.keys()[element]:
				"FIRE": 
					value = fire_res_multi
				"LIGHTNING": 
					value = lighting_res_multi
				"WATER": 
					value = water_res_multi
				"EARTH": 
					value = earth_res_multi
				"WIND": 
					value = wind_res_multi
				"ACID": 
					value = acid_res_multi
					
		resistance.set(element, value)
		print("Element: ", elements.Element.keys()[element], " resitance multi: ", resistance[element])


func change_resistance(element, multiplier:float):
	resistance.set(element, multiplier)

func get_resistance_value(element):
	print("Resistance length: ", resistance.size())
	print("Resistance test: ", resistance.get(element))
	
	return resistance.get(element)

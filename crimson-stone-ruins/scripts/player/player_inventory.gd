extends Node

const QUANTITY_BY_LEVEL = [3, 2, 2, 1]

# Ingredient are now contained into a simple array where the position is the id of the ingredient and the value is the count
var ingredients: Array[int]
var _inv_set: bool = false

var has_accesory = false
var _accessory = null  # backing variable
var accessory:
	get:
		return _accessory
	set(value):
		_accessory = value
		print("Accessory set to:", _accessory)
		emit_signal("accessory_changed")

signal accessory_changed

signal update_ui

func _ready() -> void:
	init_inventory()

func get_ing_count(id: int) -> int:
	return ingredients[id]

func add_ingredients(new_ingredients: Array[int]) -> void:
	for i in ingredients.size():
		ingredients[i] += new_ingredients[i]
	
	update_ui.emit()

func remove_ingredients(remove_ingredients: Array[int]) -> void:
	for i in ingredients.size():
		ingredients[i] -= remove_ingredients[i]
	
	update_ui.emit()

func check_availability(check_ingredients: Array[int]) -> bool:
	for i in ingredients.size():
		if ingredients[i] < check_ingredients[i]:
			return false
			
	return true

func init_inventory() -> void:
	ingredients.resize(IngredientLoader.ingredients.size())
	#ingredients.fill(3)
	for i in range(6):
		ingredients[i] = 2
	_inv_set = true
	CombatManager.refresh_player_inventory()
	
func get_base_inventory() -> Array[int]:
	var inv: Array[int]
	# Check to make sure that inventory is set
	if not _inv_set:
		init_inventory()
		
	inv.resize(IngredientLoader.ingredients.size())
	inv.fill(0)
	return inv

func empty_inventory() -> void:
	_empty_ingredients()
	_accessory = null

func _empty_ingredients() -> void:
	ingredients = []

func load_save(data: Dictionary) -> void:
	var json = JSON.new()
	
	# Ingredients
	var error = json.parse(data["ingredients"])
	if error == OK:
		var raw: Array = json.data
		var data_received: Array[int] = []

		for value in raw:
			data_received.append(int(value))
		if typeof(data_received) == TYPE_ARRAY:
			ingredients = data_received
			update_ui.emit()
		else:
			print("Unexpected data")
	else:
		print("JSON Parse Error: ", json.get_error_message(), " in ", data["ingredients"], " at line ", json.get_error_line())
	
	# Refreshes the combat player inventory after loading the saved one
	CombatManager.refresh_player_inventory()
	
	# Accessory
	error = json.parse(data["accessory"])
	if error == OK:
		var data_received = json.data
		if typeof(data_received) == TYPE_ARRAY:
			_accessory = data_received
			emit_signal("accessory_changed")
		else:
			print("Unexpected data")
	else:
		print("JSON Parse Error: ", json.get_error_message(), " in ", data["ingredients"], " at line ", json.get_error_line())

func save() -> Dictionary:
	var save_dict = {
		"name" : name,
		"ingredients" : JSON.stringify(ingredients),
		"accessory" : JSON.stringify(_accessory)
	}
	empty_inventory()
	return save_dict

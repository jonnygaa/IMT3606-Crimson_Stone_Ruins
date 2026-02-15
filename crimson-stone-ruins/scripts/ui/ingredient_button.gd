extends Button
var ingredient:Ingredient

const TEXT_COMMON = Color.WHITE
const TEXT_UNCOMMON = Color( "#B5E61D")
const TEXT_RARE = Color("#99D9EA")
const TEXT_MYTHICAL = Color("#AA26DA")

var qualities

func set_ingredient(ing:Ingredient):
	ingredient = ing
	qualities = ing.Quality
	set_button_text()

func _on_pressed():
	print("Button pressed: ", ingredient.name)
	var inv: Array[int] = PlayerInventory.get_base_inventory()
	inv[ingredient.id] = 1
	if not PlayerInventory.check_availability(inv):
		print("Not enough ", ingredient.name)
		disabled = true
		return
	
	PlayerInventory.remove_ingredients(inv)
	if not PlayerInventory.check_availability(inv):
		print("No more ", ingredient.name)
		disabled = true
	set_button_text()
	CombatManager.ingredient_order.append(ingredient)
	print(CombatManager.ingredient_order.size())

# Set the text of the button including the amount of ingredients left
func set_button_text() -> void:
	text = ingredient.name + " (" + str(PlayerInventory.get_ing_count(ingredient.id)) + ")"
	match qualities.keys()[ingredient.quality]:
		"COMMON":
			add_theme_color_override("font_color", TEXT_COMMON)
		"UNCOMMON":
			add_theme_color_override("font_color", TEXT_UNCOMMON)
		"RARE":
			add_theme_color_override("font_color", TEXT_RARE)
		"MYTHICAL":
			add_theme_color_override("font_color", TEXT_MYTHICAL)

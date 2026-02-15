extends Control

#region Variables
@onready var options_bar_element = $%OptionsBarElement
@onready var element_button_container = $%ElementButtonContainer
@onready var spell_container = $%SpellContainer
@onready var options_bar_ingredietns = $%OptionsBarIngredients
@onready var ingredient_button_container = $%IngredientButtonContainer
@onready var options_bar_main = $%OptionsBarMain
@onready var select_ingredients_button = $%SelectIngredientsButton
@onready var header:Label = $%Header
@onready var button_cursor = $ButtonIndicator
@onready var ing_order_label = $%Order
@onready var base_dmg_label = $%BaseDmg
@onready var spell_info_container = $%SpellInfo

# For tutorial
var tutorial_info: Label
var tutorial_box: ColorRect
var next_button: Button
var clear_button: Button
var confirm_button: Button
var target_button: Button 
var exec_button: Button
var Spellbook_button: Button

@export var ingredient_button_scene:PackedScene
@export var spell_button_scene:PackedScene
@export var spellbook_scene:PackedScene

# Load external resources
@onready var elements = load("res://scripts/element/elements_enum.gd")
@onready var fire_element = preload("res://scenes/combat/elements/fire.tscn")
@onready var water_element = preload("res://scenes/combat/elements/water.tscn")
@onready var acid_element = preload("res://scenes/combat/elements/acid.tscn")
@onready var lightning_element = preload("res://scenes/combat/elements/lightning.tscn")
@onready var wind_element = preload("res://scenes/combat/elements/wind.tscn")
@onready var earth_element = preload("res://scenes/combat/elements/earth.tscn")
@onready var custom_tooltip = preload("res://scenes/ui/cusotm_tooltip.tscn")

var ingredients_chosen = 0
var ingredient_slots:Array
var ingredient_button_list:Array[Array] = [ [], [], [], [], [], [] ]
var show_options:int = 0 # Used to switch between the different options

var tooltip_instance = null
var tutorial_part = 0

var turn_manager: Node = null

# remembers which spell the user clicked 
var cursor_offset
var target_cursor

var targeting: bool = false
var alive_enemies: Array[Enemy_Combat] = []
var target_index: int = 0
#endregion

func _ready() -> void:
	if get_parent().name == "CombatRoomDebug":
		cursor_offset = Vector3( -0.5, .5, 0 )
	else:
		cursor_offset = Vector3( -0.2, .15, 0 )
	
	if Globals.tutorial_flag:
		tutorial_info = $TutorialInfo
		tutorial_box = $TutorialBox
		next_button = $Next
		clear_button = $OptionsBarMain/"First selections"/Clear_button
		confirm_button = $OptionsBarMain/"First selections"/Confirm_button
		target_button = $OptionsBarMain/"Second selections"/Select_target_button
		exec_button = $OptionsBarMain/"Third selections"/Execute_button
		Spellbook_button = $OptionsBarMain/"First selections"/Spellbook
	
	createButtons()
	_connect_element_options_button_pressed_signal()


#region UI elements
func createButtons():
	for ing in CombatManager.player_ingredients:
		var ing_inv = PlayerInventory.get_base_inventory()
		ing_inv[ing.id] = 1
		if PlayerInventory.check_availability(ing_inv):
			var btn_instance = ingredient_button_scene.instantiate()
			btn_instance.set_ingredient(ing)
			
			ingredient_button_list[ing.element].append(btn_instance)
			btn_instance.pressed.connect(_on_ingredient_button_pressed.bind(btn_instance))



# Execute now only casts if we are in targeting mode. Otherwise it does nothing.
func _on_execute_button_pressed() -> void:
	if not targeting:
		return  # we haven’t selected a spell yet (no target mode)
	# Casting phase
	alive_enemies = _get_alive_enemies_sorted()
	if alive_enemies.is_empty():
		_exit_targeting()
		return
	var enemy: Enemy_Combat = alive_enemies[target_index]
	if enemy and enemy.is_alive():
		if CombatManager.has_method("execute_spell_order_on_target"):
			CombatManager.execute_spell_order_on_target(enemy)
		else:
			# fallback, will ignore targeting if helper not present
			CombatManager.execute_spell_order()

	_clear_spells()
	_exit_targeting()

	show_options = 0
	_update_options_bars()

	select_ingredients_button.disabled = false
	select_ingredients_button.mouse_entered.disconnect(_on_mouse_entered_enable_tooltip)
	select_ingredients_button.mouse_exited.disconnect(_on_mouse_exited_disable_tooltip)
	if tooltip_instance:
		tooltip_instance.queue_free()
		
	select_ingredients_button.button_pressed = false

	_clear_slots()
	
	# TurnManager Integration 
	if turn_manager:
		turn_manager.end_turn()
	# END 

func _on_clear_pressed() -> void:
	CombatManager.clear_current_spells()
	_clear_spells()
	_clear_slots()
	#Go back to the ingredient selection
	select_ingredients_button.disabled = false
	select_ingredients_button.tooltip_text = ""
	select_ingredients_button.button_pressed = false
	show_options = 0
	_hide_all_submenus()
	_update_options_bars()

func _clear_spells():
	for spell in spell_container.get_children():
		spell.queue_free()
		
	ingredients_chosen = 0

func _on_spellbook_pressed() -> void:
	var spellbook = spellbook_scene.instantiate()
	add_child(spellbook)
	
	var focused = get_viewport().gui_get_focus_owner()
	if focused:
		focused.release_focus()

func _set_element_on_circle(element) -> void:
	var slot = ingredient_slots[ingredients_chosen]
	var element_instance
	print("Button element: ", element)
	
	match element:
		"FIRE": 
			element_instance = fire_element.instantiate()
		"WATER":
			element_instance = water_element.instantiate()
		"EARTH": 
			element_instance = earth_element.instantiate()
		"ACID":
			element_instance = acid_element.instantiate()
		"WIND": 
			element_instance = wind_element.instantiate()
		"LIGHTNING":
			element_instance = lightning_element.instantiate()
			
			
	if get_parent().name == "CombatRoomDebug":
		element_instance.rotation = Vector3(45.0, 0.0, 0.0)
	
	slot.add_child(element_instance)

func _clear_slots() -> void:
	for slot in ingredient_slots:
		if 2 == slot.get_child_count():
			slot.get_child(1).queue_free()


func _fill_spell_container():
	CombatManager.create_player_attack_order()
	for spell in CombatManager.spell_order:
		var btn_instance = spell_button_scene.instantiate()
		btn_instance.set_spell(spell)
		spell_container.add_child(btn_instance)
		
		btn_instance.mouse_entered.connect(_on_mouse_entered_spell_btn.bind(btn_instance))
		btn_instance.mouse_exited.connect(_on_mouse_exited_spell_btn.bind(btn_instance))

func _on_select_button_toggled(toggled_on: bool) -> void:
	options_bar_element.visible = toggled_on
	if !toggled_on:
		options_bar_ingredietns.visible = toggled_on

func _next_option_selection():
	show_options += 1
	
	if show_options == 1:
		_fill_spell_container()
	
	_update_options_bars()
	
func _update_options_bars():
	for child in options_bar_main.get_children():
		child.visible = false
	
	options_bar_main.get_child(show_options).visible = true
	
	if 0 == show_options:
		element_button_container.visible = true
		spell_container.visible = false
		options_bar_element.visible = false 
		ingredient_button_container.visible = true
		spell_info_container.visible = false
	else:
		options_bar_ingredietns.visible = false
		element_button_container.visible = false
		spell_container.visible = true
		options_bar_element.visible = true
		ingredient_button_container.visible = false
		spell_info_container.visible = true

func _on_select_target_button_pressed() -> void:
	alive_enemies = _get_alive_enemies_sorted()
	if alive_enemies.is_empty():
		return
	
	targeting = true
	# Fixed cursor, ensures cursor exists before showing
	if target_index < 0 or target_index >= alive_enemies.size():
		target_index = 0
	_position_cursor_over(alive_enemies[target_index])
	
	_next_option_selection()

func _hide_all_submenus():
	options_bar_element.visible = false
	options_bar_ingredietns.visible = false

#endregion

# === TurnManager Integration ===
func set_turn_manager(tm: Node):
	turn_manager = tm

func enable_player_ui(enabled: bool):
	return
	#for btn in ingredient_box.get_children():
	#	btn.disabled = not enabled
	if has_node("ConfirmButton"):
		$ConfirmButton.disabled = not enabled
	if has_node("ExecuteButton"):
		$ExecuteButton.disabled = not enabled
	if has_node("ClearButton"):
		$ClearButton.disabled = not enabled
	print("Player UI", "enabled" if enabled else "disabled")

func show_victory_screen():
	#available.text = "Victory!"
	print("Victory screen shown.")

func show_defeat_screen():
	#available.text = "Defeat!"
	print("Defeat screen shown.")
# ends TurnManager Integration 

#  Targeting helpers
func _input(event: InputEvent) -> void:
	if not targeting or alive_enemies.is_empty():
		return
	
	# Left/Right to cycle targets
	if event.is_action_pressed("ui_right"):
		target_index = (target_index + 1) % alive_enemies.size()
		_update_cursor_position()
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed("ui_left"):
		target_index = (target_index - 1 + alive_enemies.size()) % alive_enemies.size()
		_update_cursor_position()
		get_viewport().set_input_as_handled()

func _get_alive_enemies_sorted() -> Array[Enemy_Combat]:
	var list: Array[Enemy_Combat] = []
	for n in get_tree().get_nodes_in_group("enemy"):
		var enemy := n as Enemy_Combat
		if enemy and enemy.is_alive():
			list.append(enemy)
	# Sorts left to right so cycling matches what you see
	list.sort_custom(func(a: Enemy_Combat, b: Enemy_Combat) -> bool:
		return a.global_position.x < b.global_position.x
	)
	return list

func _update_cursor_position() -> void:
	if not target_cursor:
		return
	if alive_enemies.is_empty():
		target_cursor.visible = false
		return
	# Fixed cursor - clamp the index after deaths/resorts
	if target_index < 0 or target_index >= alive_enemies.size():
		target_index = max(0, alive_enemies.size() - 1)
	var enemy: Enemy_Combat = alive_enemies[target_index]
	if not enemy:
		return
	
	var pos = enemy.global_position
	target_cursor.global_position = pos + cursor_offset
	target_cursor.visible = true

func _exit_targeting() -> void:
	targeting = false
	if target_cursor:
		target_cursor.visible = false

func _position_cursor_over(enemy: Enemy_Combat) -> void:
	if not target_cursor or not enemy:
		return
	var pos = enemy.global_position
	target_cursor.global_position = pos + cursor_offset
	target_cursor.visible = true


#region Signal Connections and Functions

func _on_ingredient_button_pressed(btn):
	var element = elements.Element.keys()[btn.ingredient.element]
	_set_element_on_circle(element)
	ingredients_chosen += 1
	
	var accessory_bonus = PlayerInventory.accessory[0] if PlayerInventory.accessory != null and PlayerInventory.accessory.size() > 0 else 0
	if (ingredients_chosen == 3 + accessory_bonus):
		select_ingredients_button.disabled = true
		select_ingredients_button.mouse_entered.connect(_on_mouse_entered_enable_tooltip.bind("Maximum number of ingredients reached this turn",  select_ingredients_button))
		select_ingredients_button.mouse_exited.connect(_on_mouse_exited_disable_tooltip.bind())
		options_bar_element.visible = false
		options_bar_ingredietns.visible = false
		tooltip_instance = custom_tooltip.instantiate()
		add_child(tooltip_instance)
		tooltip_instance.visible = false

func _connect_element_options_button_pressed_signal():
	var index = 0
	var i = 0
	for child in element_button_container.get_children():
		i += 1
		if  child is Button:
			child.pressed.connect(_fill_ingredient_button_container.bind(index))
			index += 1

func _fill_ingredient_button_container(index:int):
	#clear old buttons
	for child in ingredient_button_container.get_children():
		ingredient_button_container.remove_child(child)
	
	for btn:Button in ingredient_button_list[index]:
		var ing_inv = PlayerInventory.get_base_inventory()
		ing_inv[btn.ingredient.id] = 1
		if PlayerInventory.check_availability(ing_inv):
			btn.disabled = false
			btn.set_button_text()
			ingredient_button_container.add_child(btn)
		
	var element_parent = element_button_container.get_child(index) # +1 as the child at index 0 is a spacer
	var new_ingredients_bar_pos_x = element_parent.global_position.x + (element_parent.size.x / 2) - (options_bar_ingredietns.size.x / 2)
	
	options_bar_ingredietns.global_position.x = new_ingredients_bar_pos_x 
	
	options_bar_ingredietns.visible = true

func _on_mouse_entered_spell_btn(spell_btn:PanelContainer):
	if spell_btn:
		var spell = spell_btn.spell
		var order = "->".join(spell.ingredients_used)
		ing_order_label.text = str("Order: " + order)
		base_dmg_label.text = str(spell.damage)
		options_bar_ingredietns.visible = true

func _on_mouse_exited_spell_btn(spell_btn):
	if spell_btn:
		options_bar_ingredietns.visible = false

func _on_mouse_entered_enable_tooltip(text, parent):
	if !tooltip_instance:
		tooltip_instance = custom_tooltip.instantiate()
		add_child(tooltip_instance)
	const OFFSET = Vector2(0, -25)
	print("Tooltip text to set: ", text)
	
	tooltip_instance.set_text(str(text))
	tooltip_instance.global_position = parent.global_position + OFFSET
	tooltip_instance.visible = true
	
func _on_mouse_exited_disable_tooltip():
	tooltip_instance.visible = false
	
#endregion

func press_ingredient_button(btn: Button):
	btn.emit_signal("pressed")

func _on_next_button_up() -> void:
	match tutorial_part:
		0:
			tutorial_info.text = "These are your ingredients"
			select_ingredients_button.z_index = 10
			options_bar_element.z_index = 10
			select_ingredients_button.button_pressed = true
			tutorial_part += 1
		1:
			tutorial_info.text = "Higher grade increases damage"
			options_bar_ingredietns.z_index = 10
			_fill_ingredient_button_container(0)
			for ing in ingredient_button_container.get_children():
				ing.z_index = 10
			tutorial_part += 1
		2:
			tutorial_info.text ="With no accessory you
								 can use 3 per turn"
			select_ingredients_button.z_index = 0
			var accessory_bonus = PlayerInventory.accessory[0] if PlayerInventory.accessory != null and PlayerInventory.accessory.size() > 0 else 0
			for i in range(3 + accessory_bonus):
				press_ingredient_button(ingredient_button_list[elements.Element.FIRE][0])
			tutorial_part += 1
		3:
			tutorial_info.text ="The order of ingredients
								decide the spell casted"
			tutorial_part += 1
		4:
			tutorial_info.text ="     Clear spell to
								  re-choose ingredients"
			options_bar_element.z_index = 0
			clear_button.z_index = 10
			tutorial_part += 1
		5:
			tutorial_info.text = "Confirm to use ingredients"
			clear_button.z_index = 0
			confirm_button.z_index = 10
			tutorial_part += 1
		6:
			tutorial_info.text = "Hover over spell to see info"
			confirm_button.z_index = 0
			_next_option_selection()
			spell_container.z_index = 10
			_on_mouse_entered_spell_btn(spell_container.get_child(0))
			tutorial_part += 1
		7:
			tutorial_info.text = "Next, select target"
			spell_container.z_index = 0
			target_button.z_index = 10
			_on_mouse_exited_spell_btn(spell_container.get_child(0))
			tutorial_part += 1
		8:
			tutorial_info.text = "After choosing with arrow keys, 
								  execute spell to use them"
			exec_button.z_index = 10
			_on_select_target_button_pressed()
			tutorial_part += 1
		9:
			tutorial_info.text ="Order, damage and effect
						   can be seen in the\n       spellbook"
			Spellbook_button.z_index = 10
			_on_execute_button_pressed()
			tutorial_part += 1
		10:
			# Reset tutorial state
			# End of tutorial
			tutorial_info.hide()
			tutorial_box.hide()
			next_button.hide()
			next_button.disabled = true

			# Enable all buttons
			for btn in [select_ingredients_button, clear_button, confirm_button, target_button, exec_button, Spellbook_button]:
				btn.disabled = false

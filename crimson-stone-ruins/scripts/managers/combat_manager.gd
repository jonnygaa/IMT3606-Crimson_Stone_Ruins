extends Node

#Needs to be later changed to the player ingredients
var player_ingredients: Array[Ingredient] = []

#Selected Ingredient
var ingredient_order:Array[Ingredient]

#Spells in the order of creating
var spell_order:Array[Spell]
var ongoing_spell_order: Array[Spell]

# Ingredient that will be dropped after the combat
var dropped_ingredients: Array[int]

var player
var enemies
var current_enemy: PackedScene = load("res://scenes/enemies/enemy_combat.tscn")

# optional forced target, set by the UI when the player has selected one
var forced_target: Enemy_Combat = null

func _ready() -> void:
	dropped_ingredients = PlayerInventory.get_base_inventory()

func refresh_player_inventory():
	player_ingredients = get_player_ingredient_list()

func get_player_ingredient_list() -> Array[Ingredient]:
	var ingredient_list: Array[Ingredient] = []
	var inventory: Array[int] = PlayerInventory.ingredients
	for id in range(inventory.size()):
		var count = inventory[id]
		if count > 0:
			var ingredient: Ingredient = IngredientLoader.ingredients[id]
			ingredient_list.append(ingredient)

	return ingredient_list

func set_player_and_enemies(player_ref, enemies_ref):
	if player_ref:
		player = player_ref
	if enemies_ref:
		enemies = enemies_ref
		
	print("player: ", player)
	print("enemies: ", enemies)

func create_player_attack_order():
	var spells = Spellchecker.create_attack_array(ingredient_order)
	spell_order = spells

# public entry so UI can cast on a specific enemy
func execute_spell_order_on_target(target: Enemy_Combat) -> void:
	forced_target = target
	execute_spell_order()
	forced_target = null

func execute_spell_order():
	var enemies_local: Array[Enemy_Combat]
	for n in get_tree().get_nodes_in_group("enemy"):
		print(n)
		var enemy := n as Enemy_Combat
		if enemy:
			enemies_local.append(enemy)
	if enemies_local.is_empty():
		print("No enemy to hit, you win!")
		# Restore previous scene which should be the dungeon
		SceneManager.pop_scene()
		return
	
	# prefer forced target if valid otherwise keep original behavior
	var enemy: Enemy_Combat = null
	if forced_target != null and is_instance_valid(forced_target) and forced_target.is_alive():
		enemy = forced_target
	else:
		enemy = enemies.pick_random()  # original behavior
	
	# Places the spell into an ogoing array because it break when the ref spell is cleared from spell order after the turn
	ongoing_spell_order.clear()
	for spell in spell_order:
		ongoing_spell_order.append(spell)

	for spell in ongoing_spell_order:
		await spell.activation(enemy)
	
	if enemy.is_alive():
		enemy.on_turn_start()
	#if not enemy.is_alive():
		#enemies.erase(enemy)
		#enemy.queue_free()
	print("Enemie size: " + str(enemies.size()))
	if enemies.size() == 0:
		CombatManager.win_combat()
		
		# Restore previous scene which should be the dungeon
		SceneManager.pop_scene()
	
	end_turn_clean_up()

func end_turn_clean_up():
	clear_spell_order()
	clear_ingredient_order()

func end_combat_clean_up() -> void:
	clear_current_spells()
	clear_dropped_ingredients()

func clear_current_spells() -> void:
	refund_ingredients()
	clear_spell_order()
	clear_ingredient_order()

func refund_ingredients():
	var inv_ing: Array[int] = PlayerInventory.get_base_inventory()
	for ing in CombatManager.ingredient_order:
		inv_ing[ing.id] += 1
	PlayerInventory.add_ingredients(inv_ing)

func clear_spell_order() -> void:
	spell_order.clear()

func clear_ingredient_order() -> void:
	ingredient_order.clear()

func clear_dropped_ingredients() -> void:
	dropped_ingredients = PlayerInventory.get_base_inventory()

func attack_player():
	var enemies: Array[Enemy_Combat]
	for n in get_tree().get_nodes_in_group("enemy"):
		print(n)
		var enemy := n as Enemy_Combat
		if enemy:
			enemies.append(enemy)
	if enemies.is_empty():
		print("No enemy can attack!")
		return
	
	enemies.pick_random().attack()

func win_combat() -> void:
	print("you win1!")
	PlayerInventory.add_ingredients(dropped_ingredients)
	end_combat_clean_up()
	
	# Health update
	PlayerHealth.set_health(player.health.current)
	PlayerHealth.set_max_health(player.health.max)
	
	# Makes the cursor back to captured after the combat
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func add_ingredient_dropped(ing_id: int, count: int) -> void:
	dropped_ingredients[ing_id] += count

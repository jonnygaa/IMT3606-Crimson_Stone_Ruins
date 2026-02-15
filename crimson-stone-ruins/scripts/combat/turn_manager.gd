extends Node
class_name TurnManager

var player: Node
var enemies: Array = []
var ui: Control

var current_turn: String = "player"
var action_delay: float = 0.5

func setup(player_ref: Node, enemy_refs: Array, ui_ref: Control):
	player = player_ref
	enemies = enemy_refs
	ui = ui_ref
	print("TurnManager setup complete.")
	start_turn("player")

func start_turn(turn_owner: String):
	current_turn = turn_owner
	print("=== Turn Start:", current_turn, "===")

	if current_turn == "player":
		if ui.has_method("enable_player_ui"):
			ui.enable_player_ui(true)
		if player.has_method("on_turn_start"):
			player.on_turn_start()
	else:
		if ui.has_method("enable_player_ui"):
			ui.enable_player_ui(false)
		await _process_enemy_turns()
		end_turn()

func end_turn():
	print("=== Turn End:", current_turn, "===")
	if _check_combat_end():
		return

	if current_turn == "player":
		start_turn("enemy")
	else:
		start_turn("player")

func _process_enemy_turns() -> void:
	print("Enemy turn begins...")
	for enemy in enemies:
		if not is_instance_valid(enemy):
			continue
		if enemy.has_method("is_alive") and not enemy.is_alive():
			continue
		if enemy.has_method("attack"):
			enemy.attack()
			await get_tree().create_timer(action_delay).timeout
	
	print("Enemy turn ends.")

func _check_combat_end() -> bool:
	var alive_enemies := enemies.filter(func(e): return is_instance_valid(e) and e.is_alive())
	if alive_enemies.is_empty():
		print("Victory! All enemies defeated.")
		if ui.has_method("show_victory_screen"):
			ui.show_victory_screen()
		return true
	if player and player.has_method("is_alive") and not player.is_alive():
		print("Defeat! Player has died.")
		if ui.has_method("show_defeat_screen"):
			ui.show_defeat_screen()
		return true
	return false

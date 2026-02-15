extends Control

@onready var options_menu: Control = $"../OptionsMenu"
@onready var save_and_menu: Button = $VBoxContainer/SaveAndMenu
@onready var menu: Button = $VBoxContainer/Menu
@onready var save_and_exit: Button = $VBoxContainer/SaveAndExit
@onready var exit: Button = $VBoxContainer/Exit

var is_tutorial = false

func _ready() -> void:
	visible = false
	# Allows the node to play even when the game is paused
	process_mode = Node.PROCESS_MODE_ALWAYS
	
	if is_tutorial:
		_remove_save_options()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("escape") and not options_menu.visible:
		if not get_tree().paused and not visible:
			_show_game_menu()
		elif visible:
			_hide_game_menu()
	elif event.is_action_pressed("escape") and options_menu.visible:
		options_menu.hide_options_menu()

func _on_continue_pressed() -> void:
	_hide_game_menu()

func _on_options_pressed() -> void:
	visible = false
	options_menu.show_options_menu()

func _on_save_and_menu_pressed() -> void:
	_save_game()
	_go_to_menu()

func _on_menu_pressed() -> void:
	_go_to_menu()

func _on_save_and_exit_pressed() -> void:
	_save_game()
	_quit_game()

func _on_exit_pressed() -> void:
	_quit_game()

func _hide_game_menu() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	visible = false
	_play_game()

func _show_game_menu() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	visible = true
	_pause_game()

func _play_game() -> void:
	get_tree().paused = false

func _pause_game() -> void:
	get_tree().paused = true

# Inspired from https://docs.godotengine.org/en/stable/tutorials/io/saving_games.html
func _save_game() -> void:
	var save_file = FileAccess.open("user://savegame.save", FileAccess.WRITE)
		
	var save_nodes = get_tree().get_nodes_in_group("persist")
	
	save_nodes.sort_custom(func(a, b):
		return str(a.get_path()).count("/") < str(b.get_path()).count("/")
	)

	for node in save_nodes:
		# Check the node is an instanced scene so it can be instanced again during load.
		if node.scene_file_path.is_empty():
			print("persistent node '%s' is not an instanced scene, skipped" % node.name)
			continue

		# Check the node has a save function.
		if !node.has_method("save"):
			print("persistent node '%s' is missing a save() function, skipped" % node.name)
			continue

		# Call the node's save function.
		var node_data = node.call("save")

		# JSON provides a static method to serialized JSON string.
		var json_string = JSON.stringify(node_data)

		# Store the save dictionary as a new line in the save file.
		save_file.store_line(json_string)
	
	# Player inventory
	var inv_string = JSON.stringify(PlayerInventory.save())
	save_file.store_line(inv_string)
	
	# Player health
	var health_string = JSON.stringify(PlayerHealth.save())
	save_file.store_line(health_string)
	
	# Game manager
	var game_manager_string = JSON.stringify(GameManager.save())
	save_file.store_line(game_manager_string)

func _go_to_menu() -> void:
	PlayerInventory.empty_inventory()
	SceneManager.change_scene("res://scenes/ui/main_menu.tscn")
	_play_game()

func _quit_game() -> void:
	get_tree().quit()

func _remove_save_options() -> void:
	# Removes saving options
	save_and_menu.queue_free()
	save_and_exit.queue_free()
	# Renames the remaning options
	menu.text = "Go to the Menu"
	exit.text = "Exit the Game"

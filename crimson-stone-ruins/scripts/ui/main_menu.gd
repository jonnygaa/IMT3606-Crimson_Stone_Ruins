extends Control

@onready var main: Control = $Main
@onready var options_menu: Control = $OptionsMenu

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("escape") and options_menu.visible:
		options_menu.hide_options_menu()

func _on_new_game_pressed() -> void:
	GameManager.level_id = 0 # Make sure the level id is correct to start a new game
	Globals.tutorial_flag = false
	PlayerInventory.init_inventory()
	SceneManager.change_scene("res://scenes/rooms/dungeon.tscn")

func _on_load_game_pressed() -> void:
	if FileAccess.file_exists("user://savegame.save"):
		GameManager.level_id = -1
		Globals.tutorial_flag = false
		SceneManager.change_scene("res://scenes/rooms/dungeon_empty.tscn")
	else:
		_on_new_game_pressed()

func _on_tutorial_pressed() -> void:
	print("open tutorial")
	Globals.tutorial_flag = true
	PlayerInventory.init_inventory()
	SceneManager.change_scene("res://scenes/rooms/tutorial.tscn")

func _on_options_pressed() -> void:
	main.visible = false
	options_menu.visible = true

func _on_quit_pressed() -> void:
	get_tree().quit()

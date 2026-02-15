extends Control

var parent_menu: Control = null

func _ready() -> void:
	visible = false
	# Allows the node to play even when the game is paused
	process_mode = Node.PROCESS_MODE_ALWAYS
	
	# Gets either option menu or main menu depending on where we are
	if has_node("../Main"):
		parent_menu = $"../Main"
	else:
		parent_menu = $"../GameMenu"

func _on_back_pressed() -> void:
	hide_options_menu()

func show_options_menu():
	visible = true

func hide_options_menu():
	visible = false
	parent_menu.visible = true

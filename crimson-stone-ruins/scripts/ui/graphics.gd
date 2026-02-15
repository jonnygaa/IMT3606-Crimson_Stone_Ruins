extends Control

@onready var window_mode_option_button: OptionButton = $VBoxContainer/WindowModeContainer/WindowModeOptionButton
@onready var resolution_option_button: OptionButton = $VBoxContainer/ScreenResolutionContainer/ResolutionOptionButton

var _selected_window_mode: int = 0
var _selected_resolution: int = 0

const WINDOW_MODE_ARRAY: Array[String] = [
	"Full-Screen",
	"Window Mode",
	"Borderless Window",
	"Borderless Full-Screen"
]
const RESOLUTION_DISCTIONNARY: Dictionary = {
	"1152 x 648": Vector2i(1152, 648),
	"1280 x 720": Vector2i(1280, 720),
	"1920 x 1080": Vector2i(1920, 1080),
}

const GRAPHIC_SAVE_PATH = "user://graphic.save"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_add_window_mode_items()
	_add_resolution_items()
	if FileAccess.file_exists(GRAPHIC_SAVE_PATH):
		_load_graphic_options()

func _add_window_mode_items() -> void:
	for window_mode in WINDOW_MODE_ARRAY:
		window_mode_option_button.add_item(window_mode)

func _add_resolution_items() -> void:
	for resolution in RESOLUTION_DISCTIONNARY:
		resolution_option_button.add_item(resolution)

func _save_graphic_options() -> void:
	var file = FileAccess.open(GRAPHIC_SAVE_PATH, FileAccess.WRITE)
	file.store_32(_selected_window_mode)
	file.store_32(_selected_resolution)
	file.close()

func _load_graphic_options() -> void:
	var file = FileAccess.open(GRAPHIC_SAVE_PATH, FileAccess.READ)
	_selected_window_mode = file.get_32()
	_selected_resolution = file.get_32()
	file.close()
	window_mode_option_button.select(_selected_window_mode)
	resolution_option_button.select(_selected_resolution)
	_apply_window_mode(_selected_window_mode)
	_apply_resolution(_selected_resolution)

func _on_window_mode_option_button_item_selected(index: int) -> void:
	_selected_window_mode = index
	_apply_window_mode(_selected_window_mode)
	# Need to apply resolution as well, because doesn't work if applied while full-screen mode on load
	_apply_resolution(_selected_resolution)
	_save_graphic_options()

func _apply_window_mode(index: int) -> void:
	match index:
		0: # Full-Screen
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
			DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, false)
		1: # Window Mode
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
			DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, false)
		2: # Borderless Window
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
			DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, true)
		3: # Borderless Full-Screen
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
			DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, true)

func _on_resolution_option_button_item_selected(index: int) -> void:
	_selected_resolution = index
	_apply_resolution(_selected_resolution)
	_save_graphic_options()

func _apply_resolution(index: int) -> void:
	DisplayServer.window_set_size(RESOLUTION_DISCTIONNARY.values()[index])

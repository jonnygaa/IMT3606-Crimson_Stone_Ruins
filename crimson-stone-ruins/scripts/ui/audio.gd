extends Control

@onready var scroll_master: HScrollBar = $VBoxContainer/ScrollMaster
@onready var scroll_sfx: HScrollBar = $VBoxContainer/ScrollSFX
@onready var scroll_music: HScrollBar = $VBoxContainer/ScrollMusic

var _master_val: int = 100
var _sfx_val: int = 100
var _music_val: int = 100

var AUDIO_SAVE_PATH = "user://audio.save"

func _ready() -> void:
	_load_audio_options()
	scroll_master.value = _master_val
	scroll_sfx.value = _sfx_val
	scroll_music.value = _music_val

# Functions will be used to save the sounds settings
func _on_scroll_master_value_changed(value: float) -> void:
	_master_val = round(value)
	_save_audio_options()
	
func _on_scroll_sfx_value_changed(value: float) -> void:
	_sfx_val = round(value)
	_save_audio_options()

func _on_scroll_music_value_changed(value: float) -> void:
	_music_val = round(value)
	_save_audio_options()

func _save_audio_options() -> void:
	var file = FileAccess.open(AUDIO_SAVE_PATH, FileAccess.WRITE)
	file.store_32(_master_val)
	file.store_32(_sfx_val)
	file.store_32(_music_val)
	file.close()

func _load_audio_options() -> void:
	if FileAccess.file_exists(AUDIO_SAVE_PATH):
		var file = FileAccess.open(AUDIO_SAVE_PATH, FileAccess.READ)
		_master_val = file.get_32()
		_sfx_val = file.get_32()
		_music_val = file.get_32()
		file.close()
	else:
		_master_val = 100
		_sfx_val = 100
		_music_val = 100

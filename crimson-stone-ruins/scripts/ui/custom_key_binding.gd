extends Control

var current_button: Button
@onready var info_panel: PanelContainer = $PanelContainer
@onready var actions_container: VBoxContainer = $ActionsContainer  # A VBoxContainer where buttons will be added

const KEY_BINDS_SAVE_PATH = "user://key_binds.save"
var DEFAULT_KEY_BINDS_SAVE_PATH = "user://default_key_binds.save"

func _ready() -> void:
	if not FileAccess.file_exists(DEFAULT_KEY_BINDS_SAVE_PATH):
		_save_key_bind_options(DEFAULT_KEY_BINDS_SAVE_PATH)
	if FileAccess.file_exists(KEY_BINDS_SAVE_PATH):
		_load_key_bind_options()
	info_panel.hide()
	_generate_action_buttons()

func _generate_action_buttons() -> void:
	# Clear previous children if reloading
	for child in actions_container.get_children():
		child.queue_free()

	for action_name in InputMap.get_actions():
		# Skip built-in or engine actions (optional)
		if action_name.begins_with("ui_"):
			continue

		# Create a container for the button + label
		var hbox = HBoxContainer.new()

		# Label with action name
		var name_label = Label.new()
		name_label.text = action_name
		hbox.add_child(name_label)

		# Button to change key
		var button = Button.new()
		button.name = action_name
		button.text = _get_action_key_text(action_name)
		button.pressed.connect(_on_button_pressed.bind(button))
		hbox.add_child(button)

		actions_container.add_child(hbox)

func _on_button_pressed(button: Button) -> void:
	current_button = button
	info_panel.show()

# Source of _input function: https://www.gotut.net/custom-key-bindings-in-godot-4/
func _input(event: InputEvent) -> void:
	if current_button == null:
		return

	if event is InputEventKey or event is InputEventMouseButton:
		# Remove duplicate key assignments
		var all_ies: Dictionary = {}
		for ia in InputMap.get_actions():
			for iae in InputMap.action_get_events(ia):
				all_ies[iae.as_text()] = ia

		if all_ies.has(event.as_text()):
			InputMap.action_erase_events(all_ies[event.as_text()])

		# Apply the new key
		InputMap.action_erase_events(current_button.name)
		InputMap.action_add_event(current_button.name, event)

		current_button = null
		info_panel.hide()

		# Refresh all button labels
		_update_buttons()
		# Saves the new key bind
		_save_key_bind_options()

func _update_buttons() -> void:
	for hbox in actions_container.get_children():
		for child in hbox.get_children():
			if child is Button:
				child.text = _get_action_key_text(child.name)

func _get_action_key_text(action_name: String) -> String:
	var events = InputMap.action_get_events(action_name)
	return "None" if events.is_empty() else events[0].as_text()

func _save_key_bind_options(path: String = KEY_BINDS_SAVE_PATH) -> void:
	var data = {}
	for action_name in InputMap.get_actions():
		# Skip built-in or engine actions
		if action_name.begins_with("ui_"):
			continue
		
		print("Action : " + action_name + ", key: " + _get_action_key_text(action_name))
		var events = InputMap.action_get_events(action_name)
		if events.size() > 0:
			# store the InputEvent as a string
			data[action_name] = events[0].as_text()
	
	var file = FileAccess.open(path, FileAccess.WRITE)
	file.store_var(data)
	file.close()

func _load_key_bind_options() -> void:
	if FileAccess.file_exists(KEY_BINDS_SAVE_PATH):
		var file = FileAccess.open(KEY_BINDS_SAVE_PATH, FileAccess.READ)
		var data = file.get_var()
		for action_name in data.keys():
			var event_str = data[action_name]
			var event = _string_to_event(event_str)
			if event:
				InputMap.action_erase_events(action_name)
				InputMap.action_add_event(action_name, event)

func _reset_key_bind_options() -> void:
	if FileAccess.file_exists(DEFAULT_KEY_BINDS_SAVE_PATH):
		var file = FileAccess.open(DEFAULT_KEY_BINDS_SAVE_PATH, FileAccess.READ)
		var data = file.get_var()
		for action_name in data.keys():
			var event_str = data[action_name]
			print("Action name: " + action_name + ", event: " + event_str)
			var event = _string_to_event(event_str)
			if event:
				print(event)
				InputMap.action_erase_events(action_name)
				InputMap.action_add_event(action_name, event)
		_generate_action_buttons()
		_save_key_bind_options()

func _string_to_event(event_str: String) -> InputEvent:
	event_str = event_str.replace(" (Physical)", "").strip_edges()
	var event := InputEventKey.new()
	event.physical_keycode = OS.find_keycode_from_string(event_str)
	return event

func _on_reset_pressed() -> void:
	_reset_key_bind_options()

extends Control

var is_open: bool = false
@onready var slots: Array = $NinePatchRect/GridContainer.get_children()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	update_slots()
	close()
	PlayerInventory.update_ui.connect(update_slots)

func update_slots() -> void:
	for i in range(min(PlayerInventory.ingredients.size(), slots.size())):
		slots[i].update(i, PlayerInventory.ingredients[i])

func _input(event: InputEvent) -> void:
	if event.is_action("inventory") and event.is_pressed():
		if is_open:
			close()
		else:
			open()

func open():
	visible = true
	is_open = true

func close():
	visible = false
	is_open = false

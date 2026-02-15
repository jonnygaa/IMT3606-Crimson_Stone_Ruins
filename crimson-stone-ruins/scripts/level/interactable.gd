extends Area3D


@export var interact_name: String = ""
@export var is_interactable: bool = true

var interact: Callable = func():
	pass

var make_uninteractable: Callable = func():
	pass

var enter_interact_area: Callable = func():
	if is_interactable:
		label.show()

var exit_interact_area: Callable = func():
	if is_interactable:
		label.hide()

@onready var label: Label3D = $Label3D

func _ready() -> void:
	label.hide()

extends Control

@onready var camera = get_viewport().get_camera_3d()
@onready var ingredients_order: Label = $IngredientsOrder
@onready var damage: Label = $Damage

func _process(delta):
	position = Vector2(0, 40)

func set_ingredients_order(order: String) -> void:
	ingredients_order.set_text("Order: " + order)

func set_damage(val: int) -> void:
	damage.set_text("Dmg: " + str(val))

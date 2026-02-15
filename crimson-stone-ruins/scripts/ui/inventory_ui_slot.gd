extends Panel

@onready var ingredient_display: Sprite2D = $CenterContainer/Panel/IngredientDisplay
@onready var count_label: Label = $CenterContainer/Panel/CountLabel


func _ready() -> void:
	count_label.visible = false

func update(ing_id: int, count: int) -> void:
	var path = "res://resources/ingredients/"
	
	for file in DirAccess.get_files_at(path):
		if file.get_extension() == "tres":
			var ingredient:Ingredient = load(path+file)
			if ingredient.id == ing_id:
				ingredient_display.visible = true
				print("icon" + str(ingredient.icon))
				ingredient_display.texture = ingredient.icon
				count_label.text = str(count)
				if count > 0:
					count_label.visible = true
				elif count == 0:
					ingredient_display.visible = false
					count_label.visible = false

extends Node

var ingredients:Array[Ingredient]

func _ready() -> void:
	loadIngredients()

func loadIngredients():
	var path = "res://resources/ingredients/"
	
	var id = 0
	# Initialize each ingredient with a unique ID
	for file in DirAccess.get_files_at(path):
		if file.get_extension() == "tres":
			print("Ingredient was found, id : " + str(id))
			var ingredient:Ingredient = load(path+file)
			ingredient.id = id
			id += 1
			ingredient.on_loaded()
			ingredients.append(ingredient)

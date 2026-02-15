extends Node

var level_id = 0

func load_save(data: Dictionary) -> void:
	level_id = data["level_id"]

func save() -> Dictionary:
	var save_dict = {
		"name" : name,
		"level_id" : level_id
	}
	return save_dict

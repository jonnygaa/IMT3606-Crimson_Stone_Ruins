extends Node

var _max_health: int = 69
var _health: int = _max_health


func get_health() -> int:
	return _health

func get_max_health() -> int:
	return _max_health

func set_health(new_health: int) -> void:
	_health = new_health

func set_max_health(new_max_health: int) -> void:
	_max_health = new_max_health

func change_health(change: int) -> void:
	_health += change

func reset_health() -> void :
	_health = _max_health

func load_save(data: Dictionary) -> void:
	_health = data["health"]
	_max_health = data["max_health"]

func save() -> Dictionary:
	var save_dict = {
		"name" : name,
		"health" : _health,
		"max_health" : _max_health
	}
	return save_dict

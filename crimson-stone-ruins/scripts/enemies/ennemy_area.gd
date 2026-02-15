extends Area3D


# I removed the mesh instance since it looked to be only to see the rooms in the test scene.

var _enemy_area_id: int

func _ready():
	_enemy_area_id = get_instance_id()

func get_enemy_area_id() -> int:
	return _enemy_area_id

extends Node3D

var enemy

func _on_ennemy_area_body_entered(body: Node3D) -> void:
	_handle_body_entered(body)

func _on_ennemy_area_body_exited(body: Node3D) -> void:
	_handle_body_exited(body)

# There is a second zone in the room_4 of the level 3.
func _on_ennemy_area_2_body_entered(body: Node3D) -> void:
	_handle_body_entered(body)

func _on_ennemy_area_2_body_exited(body: Node3D) -> void:
	_handle_body_exited(body)

func _handle_body_entered(body: Node3D) -> void:
	if body.is_in_group("player") && enemy != null:
		enemy.chase = true

func _handle_body_exited(body: Node3D) -> void:
	if body.is_in_group("player") && enemy != null:
		enemy.chase = false

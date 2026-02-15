extends Node3D

@onready var infoArea:Control = get_tree().get_root().find_child("Tutorial_info", true, false)

var current_interactions: Array = []
var can_interact: bool = true


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("interact") and can_interact:
		if current_interactions:
			can_interact = false
			
			await current_interactions[0].interact.call()
			
			can_interact = true
			
			
			if infoArea:
				var tutorial_label := infoArea.get_node_or_null("TutorialInfo")
				if tutorial_label:
					infoArea.show_acc()
				else:
					print("Label 'TutorialInfo' not found inside 'Tutorial_info'!")
			else:
				print("infoArea node not found!")


func _process(_delta: float) -> void:
	if current_interactions and can_interact:
		current_interactions.sort_custom(sort_by_nearest)


func sort_by_nearest(area1: Area3D, area2: Area3D) -> bool:
	var area1_dist = global_position.distance_to(area1.global_position)
	var area2_dist = global_position.distance_to(area2.global_position)
	return area1_dist < area2_dist


func _on_area_3d_area_entered(area: Area3D) -> void:
	current_interactions.push_back(area)
	area.enter_interact_area.call()


func _on_area_3d_area_exited(area: Area3D) -> void:
	current_interactions.erase(area)
	area.exit_interact_area.call()

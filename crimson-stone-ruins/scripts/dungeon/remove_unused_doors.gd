# Listens on the signal to remove the unused doors once the dungeon is done generating.
extends Node

func remove_unused_doors():
	for door in $"..".get_doors():
		if door.get_room_leads_to() == null:
			door.door_node.queue_free()

# Don't forget to link the dungeon_done_generating signal to this function when creating a room
func _on_dungeon_done_generating():
	remove_unused_doors()

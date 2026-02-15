# To use in at least one room, if not, the unused doors won't be removed.
# Doesn't break if used many times, but registers the signal each time, so to avoid.
extends Node

# Registers the remove door signal to remove all the unused doors when the dungeon is done generating.
func _ready():
	$"..".connect("dungeon_done_generating", remove_unused_doors)

func remove_unused_doors():
	for door in $"..".get_doors():
		if door.get_room_leads_to() == null:
			door.door_node.queue_free()

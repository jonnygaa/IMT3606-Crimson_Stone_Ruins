extends Node

func get_children_in_group(parent: Node, group_name: String) -> Array[Node]:
	var result: Array[Node] = []
	for node in get_tree().get_nodes_in_group(group_name):
		if parent.is_ancestor_of(node):
			result.append(node)
	return result

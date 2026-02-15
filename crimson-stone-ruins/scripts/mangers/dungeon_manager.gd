extends Node
class_name DungeonManager

var dungeon_gen = null

@export var num_enemies = 2
@export var enemies_list: Dictionary[int, PackedScene] #Enemy and spawn chance
@export var boss: PackedScene
@export var chest_scene: PackedScene
var enemy_spawn_points

func _ready() -> void:
	next_dungeon()

func spawn_enemies() -> void:
	enemy_spawn_points = get_tree().get_nodes_in_group("enemy_spawn")
	
	for i in num_enemies:
		if enemy_spawn_points.size() <= i:
			print("More enemies than enemy spawns")
			return
		var node = enemy_spawn_points[i]
		
		if node.name == "BossSpawnPoint":
			print("Boss should spawn")
			var boss_scene = load("res://scenes/enemies/enemy_boss.tscn")
			var instance = boss_scene.instantiate()
			node.add_child(instance)
			node.enemy = instance
			continue

		var rand = randi_range(0, 700)
		for key in enemies_list:
			if rand <= key:
				print("Enemy should spawn")
				var enemy_scene = enemies_list[key]
				var instance = enemy_scene.instantiate()
				node.add_child(instance)
				node.enemy = instance
				break
			else:
				rand = randi_range(0, 700)

func spawn_chests() -> void:
	var chest_spawn_points = get_tree().get_nodes_in_group("chest_spawn")
	
	for i in chest_spawn_points.size():
		var node = chest_spawn_points[i]
		var instance = chest_scene.instantiate()
		node.add_child(instance)

func rotate_sprites() -> void:
	# Since the rooms can be rotated, we need to rotate the sprites to be on the same direction as the player.
	# I added the group face_player_sprite to the enemy spawn so if the enemy is not set, it rotates the spawn in which the enemy will appear.
	for sprite in get_tree().get_nodes_in_group("face_player_sprite"):
		var dungeon_generator: DungeonGenerator3D = $"../DungeonGenerator3D"
		sprite.global_rotation.y = dungeon_generator.player_instance.global_rotation.y

# Function allowing to generating the next dungeon after the exit is found
func next_dungeon() -> void:
	var level_id = GameManager.level_id
	level_id += 1
	GameManager.level_id  = level_id # Update Game manager value
	var path = "res://scenes/rooms/level_" + str(int(level_id)) + "/dungeon_generator_3d.tscn"
	if level_id == 0:
		path = "res://scenes/rooms/level_empty/dungeon_generator_3d.tscn"
	if ResourceLoader.exists(path):
		var dungeon_scene: PackedScene = load(path)
		# Drop the current dungeon generator and creates a new one.
		if not dungeon_gen == null:
			dungeon_gen.queue_free()
		await get_tree().process_frame
		dungeon_gen = dungeon_scene.instantiate()
		# Setup the dungeon generator.
		if level_id == 0:
			dungeon_gen.done_generating.connect(_load)
		else:
			dungeon_gen.done_generating.connect(rotate_sprites)
			dungeon_gen.done_generating.connect(spawn_enemies)
			dungeon_gen.done_generating.connect(spawn_chests)
		dungeon_gen.dungeon_manager = self
		# Adds the dungeon generator to the current scene.
		add_sibling.call_deferred(dungeon_gen)
	else:
		# If the last level has been beaten, we can go back to the menu.
		SceneManager.change_scene("res://scenes/ui/main_menu.tscn")

# Inspired from https://docs.godotengine.org/en/stable/tutorials/io/saving_games.html
func _load() -> void:
	if not FileAccess.file_exists("user://savegame.save"):
		return # Error! We don't have a save to load.

	# We need to revert the game state so we're not cloning objects
	# during loading. This will vary wildly depending on the needs of a
	# project, so take care with this step.
	# For our example, we will accomplish this by deleting saveable objects.
	var save_nodes = get_tree().get_nodes_in_group("persist")
	for i in save_nodes:
		i.call_deferred("free")
	# Force execution of a frame so the rooms are freed
	await get_tree().process_frame
				
	# Load the file line by line and process that dictionary to restore
	# the object it represents.
	var save_file = FileAccess.open("user://savegame.save", FileAccess.READ)
	while save_file.get_position() < save_file.get_length():
		var json_string = save_file.get_line()

		# Creates the helper class to interact with JSON.
		var json = JSON.new()

		# Check if there is any error while parsing the JSON string, skip in case of failure.
		var parse_result = json.parse(json_string)
		if not parse_result == OK:
			print("JSON Parse Error: ", json.get_error_message(), " in ", json_string, " at line ", json.get_error_line())
			continue

		# Get the data from the JSON object.
		var node_data = json.data
		
		# Player inventory
		if node_data.has("name") and node_data["name"] == PlayerInventory.name:
			PlayerInventory.load_save(node_data)
		# Player health
		elif node_data.has("name") and node_data["name"] == PlayerHealth.name:
			PlayerHealth.load_save(node_data)
		# Game manager
		elif node_data.has("name") and node_data["name"] == GameManager.name:
			GameManager.load_save(node_data)
		else:
			# Firstly, we need to create the object and add it to the tree and set its position.
			var new_object = load(node_data["filename"]).instantiate()
			new_object.name = node_data["name"]
			get_node(node_data["parent"]).add_child(new_object)
			
			new_object.position = Vector3(node_data["pos_x"], node_data["pos_y"], node_data["pos_z"])
			
			# Removes camera sliding to the player on the load
			if node_data.has("name") and node_data["name"] == "Player":
				var camera_y = new_object.movement.camera_controller.global_position.y
				new_object.movement.set_camera_position(Vector3(new_object.global_position.x, camera_y, new_object.global_position.z))
				
			# We need to use global rotation here.
			new_object.global_rotation = Vector3(node_data["rot_x"], node_data["rot_y"], node_data["rot_z"])
			
			if node_data.has("names_to_keep"):
				var names_to_keep = node_data["names_to_keep"]
				# Handles older way of making the rooms (for tha labyrinth)
				if new_object.has_node("CSGBox3D"):
					for child in new_object.get_node("CSGBox3D").get_children():
						if not child.name in names_to_keep:
							child.queue_free()
				
				# New textured rooms
				for child in new_object.get_children():
					if child.name.begins_with("RoomCell"):
						if child.get_child_count() > 0:
							for wall in child.get_children():
								if wall.get_child_count() > 0:
									var door = wall.get_child(0)
									var full_name = new_object.name + "/" + wall.name + "/" + door.name
									if not full_name in names_to_keep:
										door.queue_free()
			
			# Enemy
			if "EnemySpawnPoint" in node_data["parent"]:
				new_object.get_parent().enemy = new_object
			
			# Chest interactability
			if node_data.has("interactable") and not node_data["interactable"]:
				new_object.interactable.make_uninteractable.call()
			
			var ignore_list = ["filename", "parent", "pos_x", "pos_y", "pos_z", "rot_x", "rot_y", "rot_z", "names_to_keep", "interactable", "inventory"]
			# Now we set the remaining variables.
			for i in node_data.keys():
				if i in ignore_list:
					continue
				new_object.set(i, node_data[i])
	
	# Connects the signal to generate a new dungeon from the exit
	dungeon_gen.connect_new_dungeon_signal()

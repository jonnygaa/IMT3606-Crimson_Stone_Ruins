extends Node
class_name TutorialManager

var dungeon_gen = null

@export var num_enemies = 1
@export var enemies_list: Dictionary[int, PackedScene] #Enemy and spawn chance
var enemy_spawn_points

@onready var game_menu: Control = $"../GameMenu"

func _ready() -> void:
	game_menu.is_tutorial = true
	next_dungeon()

func spawnEnemies() -> void:
	enemy_spawn_points = get_tree().get_nodes_in_group("enemy_spawn")
	
	for i in num_enemies:
		if enemy_spawn_points.size() <= i:
			print("More enemies than enemy spawns")
			return
		var node = enemy_spawn_points[i]
		var rand = randi_range(0, 1000)
		for key in enemies_list:
			if rand <= key:
				print("Enemy should spawn")
				var enemy_scene = enemies_list[key]
				var instance = enemy_scene.instantiate()
				node.add_child(instance)
				node.enemy = instance
			else:
				rand = randi_range(0, 1000)

# Function allowing to generating the next dungeon after the exit is found
func next_dungeon() -> void:
	var path = "res://scenes/rooms/tutorial/dungeon_generator_3d.tscn"
	if ResourceLoader.exists(path):
		var dungeon_scene: PackedScene = load(path)
		# Drop the current dungeon generator and creates a new one.
		if not dungeon_gen == null:
			dungeon_gen.queue_free()
		dungeon_gen = dungeon_scene.instantiate()
		# Setup the dungeon generator.
		dungeon_gen.done_generating.connect(spawnEnemies)
		dungeon_gen.dungeon_manager = self
		# Adds the dungeon generator to the current scene.
		add_sibling.call_deferred(dungeon_gen)
	else:
		# If the last level has been beaten, we can go back to the menu.
		print("you are done with the dungeons!")
		SceneManager.change_scene("res://scenes/rooms/main.tscn")

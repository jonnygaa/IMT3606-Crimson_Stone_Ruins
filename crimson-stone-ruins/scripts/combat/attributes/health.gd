class_name Health
extends Node3D

const SpellEffects = preload("res://scripts/spells/spell_effect_enum.gd")

signal on_change(current: int, max: int) # Not sure of the utility of this one yet, it was in the tutorial, but we can easily remove it later
signal on_take_damage()
signal on_die()

enum PostDeath {DestroyNode, RestartScene, GoToMenu}

var current: int:
	set(value):
		current = clamp(value, 0, max)
		if health_bar:
			health_bar.value = current
		
		update_count_label()
	get:
		return current
@export var max: int = 100:
	set(value):
		max = value
		if health_bar:
			health_bar.max_value = value
	get:
		return max
var health_set: bool = false

var has_died: bool = false

@export var post_death_action: PostDeath

@export var current_effect: SpellEffects.SpellEffect = 0

@onready var health_bar: ProgressBar = $SubViewport/HealthBar
@onready var number_label: Label3D = $Sprite3D/NumberLaber

func _ready() -> void:
	if not health_set:
		current = max
	update_count_label()


func take_damage(amount: int):
	current -= amount
	on_change.emit(current, max)
	on_take_damage.emit()
	
	if current <= 0:
		die()
	
	health_bar.value = current
	
	update_count_label()
	
	
func die():
	# Make sure that the player or enemy or entoty can only die once
	if not has_died:
		has_died = true
		on_die.emit()
		
		if post_death_action == PostDeath.DestroyNode:
			CombatManager.enemies.erase(get_parent())
			get_parent().queue_free()

			if CombatManager.enemies.size() == 0:
				CombatManager.win_combat()
				
				# Restore previous scene which should be the dungeon
				SceneManager.pop_scene()
		elif post_death_action == PostDeath.RestartScene:
			get_tree().reload_current_scene()
		elif post_death_action == PostDeath.GoToMenu:
			SceneManager.change_scene("res://scenes/ui/main_menu.tscn")
	
	
func heal(amount: int):
	current += amount
	
	if current > max:
		current = max
	
	health_bar.value = current
	
	on_change.emit(current, max)
	
	update_count_label()

func update_count_label() -> void:
	number_label.text = str(current)

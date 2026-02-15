extends Node3D
class_name CombatEntity

@export var hp:int = 0
@export var is_player:bool = false

@onready var health: Health = $Health
@onready var defense: Defense = $Defense
@onready var speed: Speed = $Speed
@onready var resistance: Resistance = $ElementalResistance

#These are for effect triggers
var stunned:bool = false #skip turn
var extra_defense:int = 0


func _ready():
	health.max = hp
	health.current = hp
	
	resistance.init_resistances(is_player)
	print("I have " + str(health.current) + " hp")
	print("Combat entity stats:")
	print(health)
	print(defense)
	print(speed)
	print(resistance)	

func take_dmg(attack_dmg, element):
	var elemental_multi = resistance.get_resistance_value(element)
	var dmg_amount = ( attack_dmg - (defense.defense + extra_defense)) * elemental_multi
	if dmg_amount <=0:
		dmg_amount = 1
		
	health.take_damage(dmg_amount)

func heal(heal_amount):
	health.heal(heal_amount)

func on_turn_start():
	print("Player turn start")
	var effects = Utils.get_children_in_group(self, "spell_effect")
	
	for effect in effects:
		effect.trigger_effect()

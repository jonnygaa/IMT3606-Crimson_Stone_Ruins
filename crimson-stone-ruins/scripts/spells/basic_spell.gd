extends Resource
class_name Spell

const Elements = preload("res://scripts/element/elements_enum.gd")
const SpellEffects = preload("res://scripts/spells/spell_effect_enum.gd")

@export var spell_name:String
@export var element_order: Array[Elements.Element]
@export var sprite_animation:PackedScene
@export var damage:int
@export var effects_list: Array[PackedScene]
@export var buff_against_effect: SpellEffects.SpellEffect = 0

var ingredients_used: Array[String] = []

func activation(target_node: CombatEntity = null) -> void:
	# Adds animation of the spell to the target
	# TODO since we call everything at once, there might be a world where we call 
	# a short animation that kill the target without having time for the long animation to finish
	# We could maybe fix that, but it's not game breaking
	if not sprite_animation == null:
		var animation = sprite_animation.instantiate()
		target_node.add_child(animation)
		animation.position.z += 0.01
		animation.animated_sprite.animation_finished.connect(_deal_damage.bind(target_node))
	else:
		_deal_damage(target_node)

func _deal_damage(target_node: CombatEntity) -> void:
	#TODO change this to get the target node
	#Used to get access to the node tree, as it is a limitation of using extends Resource
	# NOTE: Changed to require a target; prevents accidental self-damage when clicking UI.
	if target_node == null:
		push_warning("%s activation called without target; ignoring." % spell_name)
		return

	var target = target_node
	#Some effects are added to the player
	var player = CombatManager.player

	var temp_damage = damage
	# Keep it like this for now because other more important things are not working.
	if (not buff_against_effect == 0) and target.has_node(SpellEffects.SpellEffect.find_key(buff_against_effect)):
		temp_damage = round(damage * 1.5)
	
	target.take_dmg(temp_damage, element_order[0])
	
	for effect in effects_list:
		var instance = effect.instantiate()
		#TODO implement check to which entity the effect should be added
		#E.g. Dot_effect usally the target, Defense usally caster
		if instance.name == "DefenseEffect":
			player.add_child(instance)
			instance.trigger_effect_once()
		else:
			target.add_child(instance)

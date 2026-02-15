extends CombatEntity
class_name Enemy_Combat

@export var available_spells: Array[Spell]

@export var ingredients_drop_pool: Array[Ingredient]
@export var max_ingredients: int = 5 # From 0 to x - 1

const SpellEffects = preload("res://scripts/spells/spell_effect_enum.gd")

@onready var sprite_3d: AnimatedSprite3D = $AnimatedSprite3D
@export var floating_text_scene: PackedScene
@export var damage_text_height: float = 0.6  # vertical offset above this enemy

var _base_modulate: Color = Color(1, 1, 1, 1)


func _ready() -> void:
	# Make sure base CombatEntity setup runs (HP, resistance, etc.)
	super._ready()

	if sprite_3d:
		_base_modulate = sprite_3d.modulate
	else:
		_base_modulate = Color(1, 1, 1, 1)

	print("Enemy_Combat ready on:", name)
	print("  sprite_3d =", sprite_3d)
	print("  floating_text_scene =", floating_text_scene)


# hurt flash 
func _play_hurt_flash() -> void:
	if not sprite_3d:
		print("No sprite_3d found on", name, "– cannot flash")
		return

	var tween := create_tween()
	# Flash then tween back to original color
	sprite_3d.modulate = Color(10, 0.2, 0.2, 0.2) # RED for now, adjust later
	tween.tween_property(sprite_3d, "modulate", _base_modulate, 0.25)


# 
func _find_label3d(node: Node) -> Label3D:
	if node is Label3D:
		return node

	for child in node.get_children():
		var result := _find_label3d(child)
		if result:
			return result

	return null


# floating damage text
func _show_damage_floating_text(dmg_amount: int, elemental_multi: float) -> void:
	if not floating_text_scene:
		return

	var instance = floating_text_scene.instantiate()
	if not instance:
		return

	var tag := ""
	if elemental_multi > 1.05:
		tag = "Weak "
	elif elemental_multi < 0.95:
		tag = "Resist "

	var label3d: Label3D = _find_label3d(instance)
	if label3d:
		label3d.text = "%s-%d" % [tag, dmg_amount]
	else:
		print("Floating text instance has NO Label3D inside. Children are:", instance.get_children())

	# 👉 LOCAL position above THIS enemy
	if instance is Node3D:
		instance.position = Vector3(0, damage_text_height, 0)

	# 👉 parent to this enemy, not its parent
	add_child(instance)


# override damage to add feedback (same math as CombatEntity.take_dmg) 
func take_dmg(attack_dmg, element) -> void:
	print("Enemy_Combat.take_dmg called on", name, "for", attack_dmg, "element", element)

	var elemental_multi: float = resistance.get_resistance_value(element)
	var dmg_amount: int = int((attack_dmg - (defense.defense + extra_defense)) * elemental_multi)

	if dmg_amount <= 0:
		dmg_amount = 1

	print("  elemental_multi =", elemental_multi, "final dmg =", dmg_amount)

	# Visual feedback
	_play_hurt_flash()
	_show_damage_floating_text(dmg_amount, elemental_multi)

	# Actually apply the damage (triggers Health.on_take_damage)
	health.take_damage(dmg_amount)


func _on_health_on_take_damage() -> void:
	print("Enemy health : " + str(health.current))


func _on_health_on_die() -> void:
	print("i'm dead now (enemy)")
	
	# Create the dropped ingredients
	if ingredients_drop_pool.size() > 0:
		for i in randi() % max_ingredients:
			var ing = ingredients_drop_pool[randi() % ingredients_drop_pool.size()]
			var count = PlayerInventory.QUANTITY_BY_LEVEL[ing.quality]
			CombatManager.add_ingredient_dropped(ing.id, count)


func is_alive() -> bool:
	return health.current > 0


func attack() -> void:
	var player = CombatManager.player
	
	var power_spells: Array[Spell]
	if player.has_node("StunEffect"):
		for spell in available_spells:
			if spell.buff_against_effect == SpellEffects.SpellEffect.StunEffect:
				power_spells.append(spell)
	
	# TODO We can add more effects here depending on what we want to have.
	
	if power_spells.size() > 0:
		print("Enemy attacks a power attack!")
		var spell_pos = randi() % available_spells.size()
		available_spells[spell_pos].activation(player)
	else:
		print("Enemy attacks a normal attack...")
		var spell_pos = randi() % available_spells.size()
		available_spells[spell_pos].activation(player)

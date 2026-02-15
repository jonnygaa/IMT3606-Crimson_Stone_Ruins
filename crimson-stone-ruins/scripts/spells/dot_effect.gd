extends SpellEffect

@export var dmg:int = 1
var target_hp 

func set_target_hp():
	if get_parent().get_node("Health"):
		target_hp = get_parent().get_node("Health")

func trigger_effect():
	set_target_hp()
	print("I was changed inside the dot_effect :)")
	if target_hp:
		print("Current hp: ", target_hp.current)
		target_hp.take_damage(dmg)
		print("Current hp after take dmg: ", target_hp.current)
	reduce_duration()

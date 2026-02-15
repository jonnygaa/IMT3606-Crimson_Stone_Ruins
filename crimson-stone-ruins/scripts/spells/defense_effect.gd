extends SpellEffect

@export var defense_value:int
@onready var parent = get_parent()

func trigger_effect():
	print("I was changed inside the defense_effect :)")
	reduce_duration()

#This will add to set the defense value once
func trigger_effect_once():
	parent = get_parent()
	parent.extra_defense = defense_value

func reduce_duration():
	duration = duration - 1
	if duration <= 0:
		parent.extra_defense = 0
		queue_free()
	set_duration_label()

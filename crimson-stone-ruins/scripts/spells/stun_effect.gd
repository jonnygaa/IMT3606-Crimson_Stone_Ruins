extends SpellEffect

func trigger_effect():
	print("I was changed inside the stun_effect :)")
	var target = get_parent()
	target.stunned = true
	reduce_duration()

extends CombatEntity
class_name Player_Combat

func _ready() -> void:
	super()
	health.max = PlayerHealth.get_max_health()
	health.current = PlayerHealth.get_health()
	health.health_set = true
	is_player = true

#I think this method is now handeled in the combat entity
func _on_health_on_take_damage() -> void:
	print("ouch (player)")
	print("my health : " + str(health.current))
	
func _on_health_on_die() -> void:
	# TODO reset player inventpry when dying
	health.current = hp
	print("i'm dead now (player)")

#I think this method is now handeled in the combat entity
func _on_health_on_change(current: int, max: int) -> void:
	#PlayerHealth.set_health(current)
	health.current = current

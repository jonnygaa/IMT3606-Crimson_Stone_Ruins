extends Node3D

class_name SpellEffect

@export var effect_name:String
@export var duration:int 
@onready var duration_label: Label3D = $Sprite3D/durationLabel

func _ready() -> void:
	#Add to this group to make it easy to check if effects are there
	add_to_group("spell_effect")
	set_duration_label()

#Override this class with the logic of the given effect
func trigger_effect():
	print("Spell effect ", effect_name, " triggered")
	reduce_duration()

func reduce_duration():
	duration = duration - 1
	if duration <= 0:
		queue_free()
	set_duration_label()

func set_duration_label() -> void:
	duration_label.text = str(duration)

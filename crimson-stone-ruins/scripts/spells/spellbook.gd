extends Node

var Elements = load("res://scripts/element/elements_enum.gd")
var spells:Array[Array]
var spells_acsending: Array[Array] #for UI

func _ready() -> void:
	_setup_array()

func _setup_array():
	for element in Elements.Element:
		var elementArray:Array[Spell] = []
		spells.append(elementArray)
	
	_load_spells()

func _load_spells():
	var path = "res://resources/spells/"
	
	for file in DirAccess.get_files_at(path):
		if file.get_extension() == "tres":
			var spell:Spell = ResourceLoader.load(path+file)
			spells[spell.element_order[0]].append(spell.duplicate())
			
	sort_spells()

func sort_spells():
	var temp
	for spell_type in range(0, spells.size()):
		spells[spell_type].sort_custom(_sort_spells_decsending)
		
		#Bringing spells in acending order for the spellbook UI to use
		temp = spells[spell_type].duplicate()
		temp.reverse()
		spells_acsending.append(temp)

func _sort_spells_decsending(a:Spell,b:Spell):
	if a.element_order.size() > b.element_order.size():
		return true
	#Check to have a better order structure 
	elif a.element_order.size() == b.element_order.size():
		var element = a.element_order[0]
		var index = 1
		while index < a.element_order.size():
			if a.element_order[index] != b.element_order[index]:
				if element == a.element_order[index]:
					return false
				else:
					return true

	return false

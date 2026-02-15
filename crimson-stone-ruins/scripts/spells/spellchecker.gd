extends Node
class_name Spellchecker

static func create_attack_array(ingredients:Array[Ingredient]) -> Array[Spell]:
	var spell_order:Array[Spell]
	
	var i = 0
	#Loops over the whole ingridents set by the player
	while i < ingredients.size():		
		#Gets the relavent element section of the spells
		var spells = Spellbook.spells[ingredients[i].element] # Sorted decsending
		var spell_to_add:Spell = null
		
		var spell_index = 0
		# Runs till a spell is found or the index is larger then the array has elemens
		while spells.size() > spell_index && null == spell_to_add:
			var spell:Spell = spells[spell_index]
			
			if ingredients.size() >= (spell.element_order.size() + i):

				var valid_spell:bool = true
				var ing_index = 0
				
				# Check if the ingriedent order matches a spell
				while valid_spell && spell.element_order.size() > ing_index:
					if(spell.element_order[ing_index] != ingredients[i+ing_index].element):
						valid_spell = false
					
					ing_index += 1

				if valid_spell:
					# Need to duplicate because we modify it's properties later
					spell_to_add = spell.duplicate()

			spell_index += 1

		#Check the level of the ingredient used to multiply the spell damage
		var ing_count = spell_to_add.element_order.size()
		var multiplier_total = 0
		# Resets ingredients used
		spell_to_add.ingredients_used = []
		for ii in range(i, i + ing_count):
			multiplier_total += ingredients[ii].multiplier

			spell_to_add.ingredients_used.append(ingredients[ii].name)
		
		spell_to_add.damage += multiplier_total
		
		print("Spell name: ", spell_to_add.spell_name)
		spell_order.append(spell_to_add)
		i = i + spell_to_add.element_order.size()
		
	return spell_order

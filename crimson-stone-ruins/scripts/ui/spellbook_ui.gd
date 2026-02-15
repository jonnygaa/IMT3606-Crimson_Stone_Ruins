extends Control

@onready var sprite = $Spellbook/BookSprite
@onready var spell_name_label = $"Spellbook/Info/Info-Page1/Spellname"
@onready var ingredient_order_label = $"Spellbook/Info/Info-Page1/IngredientOrder"
@onready var element_type_label = $"Spellbook/Info/Info-Page2/VBoxContainer/HBoxContainer/ElemenType"
@onready var damage_number_label = $"Spellbook/Info/Info-Page2/VBoxContainer/HBoxContainer2/DamageNumber"
#Used for listing the effects
@onready var effect_list = $"Spellbook/Info/Info-Page2/VBoxContainer/EffectList"
@onready var back_button = $"Spellbook/Info/Info-Page1/Back"
@onready var next_button = $"Spellbook/Info/Info-Page2/Next"
@onready var all_spells = Spellbook.spells_acsending
@onready var element_enum = preload("res://scripts/element/elements_enum.gd").Element

#book markers
@onready var fire_marker = $Spellbook/FireMarker
@onready var lighting_marker = $Spellbook/LightningMarker
@onready var water_marker = $Spellbook/WaterMarker
@onready var earth_marker = $Spellbook/EarthMarker
@onready var wind_marker = $Spellbook/WindMarker
@onready var acid_marker = $Spellbook/AcidMarker
@onready var active_marker = $Spellbook/FireMarker

@export var info_pages:Control

var animation_finished:bool = false
var spell_index = 0
var spell_element_index = 0
var spells
var markers:Array[Node]

const HIGHLIGHT_COLOR = Color(1, 1, 1, 1)
const UNHIGHLIGHT_COLOR = Color(.5, .5, .5, 1)

func _ready() -> void:
	spells = all_spells[0]
	info_pages.visible = false 
	back_button.visible = false
	markers = [ fire_marker, lighting_marker, water_marker, earth_marker, wind_marker, acid_marker]
	grab_focus()

func _update_spell_page():
	_check_spell_index()
	var spell = spells[spell_index]
	
	spell_name_label.text = spell.spell_name
	damage_number_label.text = str(spell.damage)
	element_type_label.text = element_enum.keys()[spell.element_order[0]]
	
	_set_ingredient_order(spell)
	_set_effects(spell)

func _set_ingredient_order(spell:Spell):
	ingredient_order_label.text = ""
	for element in spell.element_order:
		ingredient_order_label.text += element_enum.keys()[element]
		ingredient_order_label.text +=  "\n"

func _set_effects(spell:Spell):
	var label = Label.new()
	if spell.effects_list.size() == 0:
		label.text = "No Effects"
		effect_list.add_child(label)
	else:
		for effect in spell.effects_list:
			var instance = effect.instantiate()
			label.text = instance.effect_name
			instance.queue_free()
			effect_list.add_child(label)

func _input(event: InputEvent) -> void:
	if animation_finished:
		
		if event.is_action_pressed("ui_left"):
			_show_previous_page()
				
		if event.is_action_pressed("ui_right"):
			_show_next_page()
			
		if event.is_action_pressed("ui_down"):
			if spell_element_index < all_spells.size() - 1:
				_change_spell_element_index(spell_element_index + 1)
				sprite.play_next_page_animation()
			
		if event.is_action_pressed("ui_up"):
			if spell_element_index > 0:
				_change_spell_element_index(spell_element_index - 1)
				sprite.play_previous_page_animation()
			
		if event.is_action_pressed("ui_cancel"):
			sprite.play_close_animation()

func _on_book_sprite_animation_finished() -> void:
	if sprite.animation == "close":
		queue_free()
	else:
		animation_finished = true
		_update_spell_page()
		info_pages.visible = true

func _on_book_sprite_animation_changed() -> void:
	animation_finished = false

func _on_book_sprite_animation_started() -> void:
	animation_finished = false
	info_pages.visible = false
	for child in effect_list.get_children():
		child.free()

func _on_close_pressed() -> void:
	queue_free()

func _on_back_button_down() -> void:
	_show_previous_page()

func _on_next_button_down() -> void:
	_show_next_page()

func _check_spell_index():
	if  spells.size()-1 == spell_index:
		next_button.visible = false
		back_button.visible = true
	elif 0 == spell_index:
		next_button.visible = true
		back_button.visible = false
	else:
		next_button.visible = true
		back_button.visible = true

func _on_fire_marker_button_pressed() -> void:
	sprite.play_previous_page_animation()
	_change_marker_highlight(fire_marker)
	_change_spell_element_index(0)

func _on_lightning_marker_button_pressed() -> void:
	sprite.play_previous_page_animation()
	_change_marker_highlight(lighting_marker)
	_change_spell_element_index(1)

func _on_water_marker_button_pressed() -> void:
	sprite.play_previous_page_animation()
	_change_marker_highlight(water_marker)
	_change_spell_element_index(2)

func _on_earth_marker_button_pressed() -> void:
	sprite.play_previous_page_animation()
	_change_marker_highlight(earth_marker)
	_change_spell_element_index(3)

func _on_wind_marker_button_pressed() -> void:
	sprite.play_previous_page_animation()
	_change_marker_highlight(wind_marker)
	_change_spell_element_index(4)

func _on_acid_marker_button_pressed() -> void:
	sprite.play_previous_page_animation()
	_change_marker_highlight(acid_marker)
	_change_spell_element_index(5)

func _change_marker_highlight(node):
	active_marker.modulate = UNHIGHLIGHT_COLOR
	active_marker = node
	active_marker.modulate = HIGHLIGHT_COLOR

func _change_spell_element_index(index):
	spell_element_index = index
	spells = all_spells[spell_element_index]
	spell_index = 0
	_change_marker_highlight(markers[spell_element_index])
	_update_spell_page()

func _show_next_page():
	if spell_index < spells.size()-1:
		spell_index += 1
		sprite.play_next_page_animation()
	elif spell_index == spells.size()-1:
		var i = markers.find(active_marker)
		if all_spells.size()-1 >= i + 1:
			_change_spell_element_index(i + 1)
			sprite.play_next_page_animation()
			
func _show_previous_page():
	if spell_index > 0:
		spell_index -= 1
		sprite.play_previous_page_animation()
	elif spell_index == 0:
		var i = markers.find(active_marker)
		if 0 <= i - 1:
			_change_spell_element_index(i - 1)
			spell_index = spells.size() - 1
			sprite.play_previous_page_animation()

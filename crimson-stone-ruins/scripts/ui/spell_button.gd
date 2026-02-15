extends PanelContainer

var spell:Spell

var normal_style = preload("res://resources/ui/panel_style_spell_normal.tres")
var hover_style = preload("res://resources/ui/panel_style_spell_hover.tres")

func set_spell(spl:Spell):
	var label = $MarginContainer/Label
	spell = spl
	label.text = spell.spell_name


func _on_mouse_entered() -> void:
	remove_theme_stylebox_override("panel")
	# Get a StyleBox from the theme
	add_theme_stylebox_override("panel", hover_style)



func _on_mouse_exited() -> void:
	remove_theme_stylebox_override("panel")
	# Get a StyleBox from the theme
	add_theme_stylebox_override("panel", normal_style)

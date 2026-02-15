extends Control
@onready var label = $PanelContainer/MarginContainer/RichTextLabel

func set_text(text):
	label.text = text

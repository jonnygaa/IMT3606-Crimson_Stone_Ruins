extends Control

@onready var tutorialInfo:Label = $"TutorialInfo"
@onready var accColor:ColorRect = $"AccColor"
@onready var eqColor:ColorRect = $"EqColor"

func _ready():
	hide_acc()
	mouse_filter = Control.MOUSE_FILTER_IGNORE

func show_acc():
	tutorialInfo.visible = false
	accColor.visible = true
	eqColor.visible = true

func hide_acc():
	tutorialInfo.visible = true
	accColor.visible = false
	eqColor.visible = false

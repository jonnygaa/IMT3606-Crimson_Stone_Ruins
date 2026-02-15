extends AnimatedSprite2D

signal animation_started

func play_open_animation():
	animation_started.emit()
	play("open")
	pass
	
func play_close_animation():
	animation_started.emit()
	play("close")
	pass
	
func play_next_page_animation():
	animation_started.emit()
	play("next_page")
	pass
	
func play_previous_page_animation():
	animation_started.emit()
	play("previous_page")
	pass

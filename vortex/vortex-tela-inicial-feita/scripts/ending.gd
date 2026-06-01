extends Node2D

func _process(delta):
	if Input.is_anything_pressed():
		get_tree().quit()

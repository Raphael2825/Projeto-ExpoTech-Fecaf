extends Control

func _input(event):
	if event is InputEventJoypadButton and event.pressed:
		_on_iniciar_pressed()

func _on_iniciar_pressed():
	get_tree().change_scene_to_file("res://cenas/level1.tscn")

extends Area2D

@export var coop_camera : Camera2D
@export var camera_point : Marker2D
@export var arena_zoom := Vector2(1.3, 1.3)

var activated := false

func _ready():
	print("BOSS ZOOM SCRIPT CARREGADO")
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D) -> void:
	print("ENTROU NA BOSS ZONE: ", body.name)

	if activated:
		return

	if not body.is_in_group("player"):
		return

	activated = true

	if coop_camera and camera_point:
		coop_camera.lock_to_boss_arena(
			camera_point.global_position,
			arena_zoom
		)

extends Camera2D

@export var player1 : Node2D
@export var player2 : Node2D

@export var min_zoom := 1.5
@export var max_zoom := 3


@export var zoom_speed := 5.0
@export var follow_speed := 5.0

@export var intensidade_mira := 0.25

var boss_mode := false
var boss_camera_position := Vector2.ZERO
var boss_zoom := Vector2(1.0, 1.0)

func _process(delta):
	if boss_mode:
		global_position = global_position.lerp(
			boss_camera_position,
			delta * follow_speed
		)

		zoom = zoom.lerp(
			boss_zoom,
			delta * zoom_speed
		)

		return

	if not player1 or not player2:
		return

	update_position(delta)
	update_zoom(delta)

func update_position(delta):
	var center_pos = (
		player1.global_position +
		player2.global_position
	) / 2

	var deslocamento_miras := Vector2.ZERO

	var mira1 = player1.find_child("MiraControle")
	if mira1:
		deslocamento_miras += mira1.position

	var mira2 = player2.find_child("MiraControle")
	if mira2:
		deslocamento_miras += mira2.position

	var espiada = (
		deslocamento_miras / 2
	) * intensidade_mira

	var target_pos = center_pos + espiada

	global_position = global_position.lerp(
		target_pos,
		delta * follow_speed
	)

func update_zoom(delta):
	var distance = player1.global_position.distance_to(
		player2.global_position
	)

	var target_zoom = clamp(
		max_zoom - (distance / 800.0),
		min_zoom,
		max_zoom
	)

	zoom = zoom.lerp(
		Vector2(target_zoom, target_zoom),
		delta * zoom_speed
	)

func lock_to_boss_arena(pos: Vector2, new_zoom := Vector2(1.0, 1.0)):
	boss_mode = true
	boss_camera_position = pos
	boss_zoom = new_zoom

func unlock_boss_arena():
	boss_mode = false

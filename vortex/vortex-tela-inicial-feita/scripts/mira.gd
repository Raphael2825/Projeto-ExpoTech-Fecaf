extends Node2D

@export var mira_cor: Color = Color.CYAN:
	set(value):
		mira_cor = value
		queue_redraw()

@export var contorno_cor: Color = Color.BLACK:
	set(value):
		contorno_cor = value
		queue_redraw()

@export var tamanho_linha: float = 5.0:
	set(value):
		tamanho_linha = value
		queue_redraw()

@export var espessura: float = 2.0:
	set(value):
		espessura = value
		queue_redraw()

@export var escala_mira: float = 1.0
@export var raio_orbita: float = 50.0
@export var centro_orbita_offset := Vector2(0, -10)
@export var mira_visual_offset := Vector2.ZERO

@onready var player = get_owner()

var p_id: int = 1
var aim_direction := Vector2.RIGHT

func _ready() -> void:
	if player and "player_id" in player:
		p_id = player.player_id

	position = centro_orbita_offset + aim_direction * raio_orbita + mira_visual_offset
	scale = Vector2.ONE * escala_mira
	queue_redraw()

func _draw() -> void:
	draw_line(Vector2(-tamanho_linha - 1, 0), Vector2(tamanho_linha + 1, 0), contorno_cor, espessura + 2.0)
	draw_line(Vector2(0, -tamanho_linha - 1), Vector2(0, tamanho_linha + 1), contorno_cor, espessura + 2.0)

	draw_line(Vector2(-tamanho_linha, 0), Vector2(-1, 0), mira_cor, espessura)
	draw_line(Vector2(1, 0), Vector2(tamanho_linha, 0), mira_cor, espessura)
	draw_line(Vector2(0, -tamanho_linha), Vector2(0, -1), mira_cor, espessura)
	draw_line(Vector2(0, 1), Vector2(0, tamanho_linha), mira_cor, espessura)

	draw_rect(Rect2(-2, -2, 4, 4), contorno_cor)
	draw_rect(Rect2(-1, -1, 2, 2), mira_cor)

func _process(_delta: float) -> void:
	var suffix := "_p" + str(p_id)

	var input_vector := Vector2.ZERO
	input_vector.x = Input.get_action_strength("aim_right" + suffix) - Input.get_action_strength("aim_left" + suffix)
	input_vector.y = Input.get_action_strength("aim_down" + suffix) - Input.get_action_strength("aim_up" + suffix)

	if input_vector.length() > 0.2:
		aim_direction = input_vector.normalized()
	else:
		if player and player.has_node("AnimatedSprite2D"):
			var facing = -1 if player.get_node("AnimatedSprite2D").flip_h else 1
			aim_direction = Vector2(facing, 0)

	position = centro_orbita_offset + aim_direction * raio_orbita + mira_visual_offset
	scale = Vector2.ONE * escala_mira

	var gun_pivot = player.find_child("GunPivot")
	if gun_pivot:
		gun_pivot.rotation = aim_direction.angle()

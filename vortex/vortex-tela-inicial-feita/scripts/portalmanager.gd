extends Node

var portal_scene = preload(
	"res://cenas/portal.tscn"
)

var portal_a = null
var portal_b = null

var max_distance := 1200.0

func create_portal(pos, direction, player_id):

	# ====================
	# PLAYER 1 -> AZUL
	# ====================
	if player_id == 1:

		# LIMPA REFERÊNCIAS
		if portal_a:

			if portal_b:
				portal_b.target_portal = null

			portal_a.queue_free()
			portal_a = null

		portal_a = portal_scene.instantiate()

		get_tree().current_scene.add_child(
			portal_a
		)

		portal_a.global_position = pos
		portal_a.global_rotation = 0

		adjust_portal_position(
			portal_a,
			direction
		)

		portal_a.modulate = Color.DARK_RED

	# ====================
	# PLAYER 2 -> LARANJA
	# ====================
	elif player_id == 2:

		# LIMPA REFERÊNCIAS
		if portal_b:

			if portal_a:
				portal_a.target_portal = null

			portal_b.queue_free()
			portal_b = null

		portal_b = portal_scene.instantiate()

		get_tree().current_scene.add_child(
			portal_b
		)

		portal_b.global_position = pos
		portal_b.global_rotation = 0

		adjust_portal_position(
			portal_b,
			direction
		)

		portal_b.modulate = Color.DARK_GOLDENROD

	connect_portals()

# ====================
# CONECTA PORTAIS
# ====================

func connect_portals():

	if not portal_a:
		return

	if not portal_b:
		return

	var dist = portal_a.global_position.distance_to(
		portal_b.global_position
	)

	# LIMITE DISTÂNCIA
	if dist > max_distance:
		return

	portal_a.target_portal = portal_b
	portal_b.target_portal = portal_a

# ====================
# AJUSTE VISUAL
# ====================

func adjust_portal_position(portal, direction):

	# CHÃO
	if direction.y > 0.7:

		portal.global_position.y -= 20

	# TETO
	elif direction.y < -0.7:

		portal.global_position.y += 22

	# PAREDE DIREITA
	elif direction.x > 0.7:

		portal.global_position.x -= 12

	# PAREDE ESQUERDA
	elif direction.x < -0.7:

		portal.global_position.x += 8
		
		
		
		
# ====================
# LIMPAR PORTAL DO PLAYER
# ====================

func clear_player_portal(player_id):

	if player_id == 1:

		if portal_a:

			if portal_b:
				portal_b.target_portal = null

			portal_a.queue_free()
			portal_a = null

	elif player_id == 2:

		if portal_b:

			if portal_a:
				portal_a.target_portal = null

			portal_b.queue_free()
			portal_b = null

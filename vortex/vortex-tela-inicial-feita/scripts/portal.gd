extends Area2D

var target_portal = null

var can_teleport := true

func _on_body_entered(body):

	# ====================
	# SOMENTE PLAYERS
	# ====================
	if not body.is_in_group("player"):
		return

	# ====================
	# PRECISA TER PORTAL CONECTADO
	# ====================
	if target_portal == null:
		return

	# EVITA REFERÊNCIA INVÁLIDA
	if not is_instance_valid(target_portal):
		return

	# ====================
	# EVITA LOOP INFINITO
	# ====================
	if not can_teleport:
		return

	# ====================
	# TELEPORTE
	# ====================
	body.global_position = (
		target_portal.global_position
	)

	# ====================
	# BLOQUEIA TELEPORTE TEMPORARIAMENTE
	# ====================
	can_teleport = false
	target_portal.can_teleport = false

	await get_tree().create_timer(0.3).timeout

	# CONFERE SE AINDA EXISTEM
	if not is_instance_valid(self):
		return

	if not is_instance_valid(target_portal):
		return

	can_teleport = true
	target_portal.can_teleport = true

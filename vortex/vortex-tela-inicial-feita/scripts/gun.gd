extends Node2D

@export var bullet_scene : PackedScene
@export var portal_bullet_scene : PackedScene

@export var player_id := 1

@export var shoot_origin_offset := Vector2(0, -10)

@onready var player = get_parent().get_parent()

var aim_direction := Vector2.RIGHT

var can_shoot_portal := true
var can_shoot_normal := true

func _process(delta):
	handle_aim()
	handle_shoot()
	handle_clear_portal()

func handle_aim():
	var mira_node = player.find_child("mira")

	if mira_node:
		aim_direction = mira_node.aim_direction.normalized()

func handle_shoot():
	if Input.is_action_just_pressed("shoot_p" + str(player_id)):
		if can_shoot_normal:
			shoot_normal()

	if Input.is_action_just_pressed("portal_p" + str(player_id)):
		if can_shoot_portal:
			shoot_portal()

func handle_clear_portal():
	if Input.is_action_just_pressed("clear_portal_p" + str(player_id)):
		portalmanager.clear_player_portal(player_id)

func shoot_normal():
	if not player.use_mana(20):
		return

	can_shoot_normal = false

	var bullet = bullet_scene.instantiate()
	get_tree().current_scene.add_child(bullet)

	bullet.global_position = player.global_position + shoot_origin_offset
	bullet.direction = aim_direction

	start_normal_cooldown()

func shoot_portal():
	if not player.use_mana(40):
		return

	can_shoot_portal = false

	var portal_bullet = portal_bullet_scene.instantiate()

	var spawn_pos = player.global_position + shoot_origin_offset
	spawn_pos += aim_direction * 12

	portal_bullet.global_position = spawn_pos
	portal_bullet.direction = aim_direction
	portal_bullet.owner_player_id = player_id
	portal_bullet.gun_reference = self

	get_tree().current_scene.add_child(portal_bullet)

func start_normal_cooldown():
	await get_tree().create_timer(0.25).timeout
	can_shoot_normal = true

func start_portal_cooldown():
	await get_tree().create_timer(1.0).timeout
	can_shoot_portal = true

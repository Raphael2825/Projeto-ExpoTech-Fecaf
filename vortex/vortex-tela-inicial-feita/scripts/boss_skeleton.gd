extends CharacterBody2D

@export var speed := 40.0
@export var health := 12
@export var damage := 1

@export var right_limit_offset := 100.0
@export var left_limit_offset := 0.0

@export var boss_center_offset_x := 0.0

@export var attack_recovery_time := 0.45

# Tempo que espera depois da animação Dead antes de ir para a tela final
@export var ending_delay := 2.0

@onready var anim: AnimatedSprite2D = $AnimatedSprite2D

@export var left_limit: Marker2D
@export var right_limit: Marker2D
@export var left_damage_area: Area2D
@export var right_damage_area: Area2D

@export_file("*.tscn") var ending_scene: String

var direction := 1
var is_attacking := false
var is_dead := false
var current_attack_side := ""

var can_trigger_attack := true
var last_attack_side := ""
var attack_recovery_timer := 0.0
var is_flashing := false

func _ready():
	add_to_group("enemy")

	if left_damage_area:
		left_damage_area.monitoring = true

	if right_damage_area:
		right_damage_area.monitoring = true

func _physics_process(delta):
	if is_dead:
		return

	if attack_recovery_timer > 0:
		attack_recovery_timer -= delta
		can_trigger_attack = false
	else:
		can_trigger_attack = true

	if not is_on_floor():
		velocity += get_gravity() * delta
	else:
		velocity.y = 0

	if is_attacking:
		velocity.x = 0
		move_and_slide()
		return

	velocity.x = direction * speed
	anim.flip_h = direction < 0

	if is_on_floor():
		anim.play("walk")

	move_and_slide()

	if not can_trigger_attack:
		return

	check_limits_after_movement()

func check_limits_after_movement():
	var check_x = global_position.x + boss_center_offset_x

	if direction > 0:
		if right_limit and check_x >= right_limit.global_position.x - right_limit_offset:
			start_attack("right")
			return

		if is_on_wall():
			var normal = get_wall_normal()

			if normal.x < 0:
				start_attack("right")
				return

	if direction < 0:
		if left_limit and check_x <= left_limit.global_position.x + left_limit_offset:
			start_attack("left")
			return

func start_attack(side: String):
	if is_attacking or is_dead:
		return

	if side == last_attack_side:
		return

	is_attacking = true
	current_attack_side = side
	last_attack_side = side
	velocity.x = 0

	if side == "left":
		anim.flip_h = true
	else:
		anim.flip_h = false

	anim.speed_scale = 0.6
	anim.play("Attack")

func finish_attack():
	apply_attack_damage()

	anim.speed_scale = 1.0
	is_attacking = false

	if current_attack_side == "right":
		direction = -1
	elif current_attack_side == "left":
		direction = 1

	current_attack_side = ""
	anim.play("walk")

	attack_recovery_timer = attack_recovery_time

func apply_attack_damage():
	var area: Area2D = null
	print("APLICANDO DANO: ", current_attack_side)

	if current_attack_side == "left":
		area = left_damage_area
	elif current_attack_side == "right":
		area = right_damage_area

	if area == null:
		return

	for body in area.get_overlapping_bodies():
		if body.is_in_group("player") and body.has_method("take_damage"):
			body.take_damage(damage)

func take_damage(amount: int):
	if is_dead:
		return

	health -= amount

	if health <= 0:
		die()
		return

	flash_damage()

func flash_damage():
	if is_flashing:
		return

	is_flashing = true

	var old_modulate = anim.modulate
	anim.modulate = Color.RED

	await get_tree().create_timer(0.08).timeout

	if is_instance_valid(anim):
		anim.modulate = old_modulate

	is_flashing = false

func die():
	is_dead = true
	velocity = Vector2.ZERO
	anim.speed_scale = 1.0
	anim.play("Dead")

	if has_node("CollisionShape2D"):
		$CollisionShape2D.set_deferred("disabled", true)

func _on_animated_sprite_2d_animation_finished():
	if anim.animation == "Attack":
		finish_attack()
		return

	if anim.animation == "Dead":
		await get_tree().create_timer(ending_delay).timeout

		if ending_scene != "":
			get_tree().change_scene_to_file(ending_scene)
		else:
			queue_free()

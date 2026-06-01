extends CharacterBody2D

@onready var anim: AnimatedSprite2D = $AnimatedSprite2D
@onready var death_line: Marker2D = $"../death_line"

# HEALTH BAR
@onready var health_bar: TextureProgressBar = find_child("HealthBar")

# MANA BAR
@onready var mana_bar: TextureProgressBar = find_child("ManaBar")

@onready var gun = $GunPivot/Gun

const SPEED = 100.0
const JUMP_VELOCITY = -300.0
const MAX_JUMPS = 2

@export var player_id := 1

# OFFSET DO SPRITE
@export var left_offset := -20
@export var right_offset := 20

# VIDA
var max_health := 100
var health := 100

# MANA
var max_mana := 100.0
var mana := 100.0

@export var mana_regen_speed := 12.0

var jump_count = 0

func _ready() -> void:

	add_to_group("player")

	# CONFIGURA HEALTH BAR
	if health_bar:

		health_bar.max_value = max_health
		health_bar.value = health

	# CONFIGURA MANA BAR
	if mana_bar:

		mana_bar.max_value = max_mana
		mana_bar.value = mana

	gun.player_id = player_id

func _physics_process(delta: float) -> void:

	# GRAVIDADE
	if not is_on_floor():

		velocity += get_gravity() * delta

	else:

		jump_count = 0

	# MORTE POR QUEDA
	if death_line:

		if global_position.y > death_line.global_position.y:

			die()

	# PULO
	if Input.is_action_just_pressed(
		"jump_p" + str(player_id)
	):

		if jump_count < MAX_JUMPS:

			velocity.y = JUMP_VELOCITY

			jump_count += 1

	# MOVIMENTO
	var direction := Input.get_axis(

		"left_p" + str(player_id),
		"right_p" + str(player_id)

	)

	if direction:
		velocity.x = direction * SPEED
		var facing_left = direction < 0

		# FLIP DO SPRITE (Deixe apenas isso!)
		anim.flip_h = facing_left
	else:

		velocity.x = move_toward(
			velocity.x,
			0,
			SPEED
		)

	_update_animations(direction)

	move_and_slide()

	# REGENERA MANA
	regen_mana(delta)

# ====================
# ANIMAÇÕES
# ====================

func _update_animations(direction):

	if not is_on_floor():

		anim.play("pulo")

	elif direction != 0:

		anim.play("andando")

	else:

		anim.play("parado")

# ====================
# DANO
# ====================

func take_damage(amount: int):

	health -= amount

	# LIMITA VIDA
	health = clamp(
		health,
		0,
		max_health
	)

	# ANIMA BARRA DE VIDA
	if health_bar:

		var health_tween = create_tween()

		health_tween.tween_property(
			health_bar,
			"value",
			health,
			0.2
		)

	# FLASH DE DANO
	var damage_tween = create_tween()

	damage_tween.tween_property(
		anim,
		"modulate",
		Color.RED,
		0.1
	)

	damage_tween.tween_property(
		anim,
		"modulate",
		Color.WHITE,
		0.1
	)

	# MORTE
	if health <= 0:

		die()

# ====================
# MANA
# ====================

func use_mana(amount):

	if mana >= amount:

		mana -= amount

		mana = clamp(
			mana,
			0.0,
			max_mana
		)

		if mana_bar:

			var mana_tween = create_tween()

			mana_tween.tween_property(
				mana_bar,
				"value",
				round(mana),
				0.15
			)

		return true

	return false

func regen_mana(delta):

	if mana < max_mana:

		mana += mana_regen_speed * delta

		mana = clamp(
			mana,
			0.0,
			max_mana
		)

		if mana_bar:

			mana_bar.value = round(mana)

# ====================
# MORTE
# ====================

func die():

	get_tree().reload_current_scene()

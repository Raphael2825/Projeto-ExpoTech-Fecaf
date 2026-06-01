extends CharacterBody2D

# --- CONSTANTES ---
const SPEED = 50.0
const CHASE_SPEED = 75.0
const DAMAGE_AMOUNT = 25

# --- REFERÊNCIAS ---
@onready var wall_detector: RayCast2D = $wall_detector
@onready var anim: AnimatedSprite2D = $AnimatedSprite2D
@onready var attack_area: Area2D = $AttackArea
@onready var detection_area: Area2D = $DetectionArea
@onready var attack_timer: Timer = $AttackTimer

# --- VARIÁVEIS DE CONTROLE ---
var direction := 1
var health := 3
var is_dead := false
var player: Node2D = null
var can_attack := true
var has_hit_player := false 

func _ready() -> void:
	add_to_group("enemy")
	anim.frame_changed.connect(_on_animation_frame_changed)

func _physics_process(delta: float) -> void:
	if is_dead: return

	_apply_gravity(delta)
	_handle_movement()
	_update_facing()
	_update_animations()
	move_and_slide()
# ====================
# MOVIMENTAÇÃO E IA
# ====================
func _apply_gravity(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta

func _handle_movement() -> void:
	if anim.animation == "Attack" and anim.is_playing():
		velocity.x = 0
		return

	if wall_detector.is_colliding() or is_on_wall():
		direction *= -1

	if player:
		direction = sign(player.global_position.x - global_position.x)
		
		if _is_player_in_attack_range():
			velocity.x = 0
		else:
			velocity.x = direction * CHASE_SPEED
	else:
		velocity.x = direction * SPEED

func _update_facing() -> void:
	if anim.animation == "Attack" and anim.is_playing():
		return

	var facing_left = direction < 0
	anim.flip_h = facing_left
	
	var modifier = -1 if facing_left else 1
	attack_area.position.x = 18 * modifier
	detection_area.position.x = 25 * modifier
	
	wall_detector.target_position.x = 7 * modifier
# ====================
# COMBATE / ATAQUE
# ====================
func _is_player_in_attack_range() -> bool:
	for body in attack_area.get_overlapping_bodies():
		if body.is_in_group("player"):
			return true
	return false

func _on_attack_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("player") and can_attack and not is_dead:
		_start_attack()

func _start_attack() -> void:
	can_attack = false
	has_hit_player = false 
	velocity.x = 0
	anim.play("Attack")
	attack_timer.start()

func _on_animation_frame_changed() -> void:
	if anim.animation == "Attack" and anim.frame == 8 and not has_hit_player:
		deal_damage()

func deal_damage() -> void:
	has_hit_player = true
	for body in attack_area.get_overlapping_bodies():
		if body.is_in_group("player") and body.has_method("take_damage"):
			body.take_damage(DAMAGE_AMOUNT)

func _on_attack_timer_timeout() -> void:
	can_attack = true
	if _is_player_in_attack_range() and not is_dead:
		_start_attack()
# ====================
# DETECÇÃO DE JOGADOR
# ====================
func _on_detection_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		player = body

func _on_detection_area_body_exited(body: Node2D) -> void:
	if body == player:
		player = null
# ====================
# SISTEMA DE DANO E ANIMAÇÕES
# ====================
func take_damage(amount: int) -> void:
	if is_dead: return
	
	health -= amount
	if health <= 0:
		_die()
	else:
		anim.play("hit")

func _die() -> void:
	is_dead = true
	velocity.x = 0
	anim.play("Dead")
	$CollisionShape2D.set_deferred("disabled", true)

func _update_animations() -> void:
	if anim.is_playing() and anim.animation in ["Attack", "hit", "Dead"]:
		return
	if is_on_floor() and abs(velocity.x) > 10:
		anim.play("walk")
	else:
		anim.play("idle")
		
func _on_animated_sprite_2d_animation_finished() -> void:
	match anim.animation:
		"Dead":
			await get_tree().create_timer(1.5).timeout
			queue_free()
		"Attack", "hit":
			anim.play("idle")
			if _is_player_in_attack_range() and can_attack and not is_dead:
				_start_attack()

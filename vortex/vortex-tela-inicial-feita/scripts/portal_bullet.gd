extends CharacterBody2D

@export var speed := 900
@export var max_distance := 900.0

var owner_player_id := 1
var gun_reference = null
var direction := Vector2.RIGHT

var start_position := Vector2.ZERO

func _ready():
	start_position = global_position
	direction = direction.normalized()

func _physics_process(delta):
	var distance_traveled = global_position.distance_to(start_position)

	if distance_traveled >= max_distance:
		_destroy_and_reset()
		return

	var collision = move_and_collide(direction * speed * delta)

	if collision:
		var portal_pos = collision.get_position()

		portalmanager.create_portal(
			portal_pos,
			direction,
			owner_player_id
		)

		_destroy_and_reset()

func _destroy_and_reset():
	if gun_reference:
		gun_reference.start_portal_cooldown()

	queue_free()

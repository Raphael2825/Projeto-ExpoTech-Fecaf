extends Area2D

@export var speed := 900
@export var damage := 25

var direction := Vector2.RIGHT

func _physics_process(delta):

	global_position += direction * speed * delta

func _on_body_entered(body):

	print("BULLET BATEU EM: ", body.name)

	if body.is_in_group("player"):
		return

	if body.is_in_group("enemy"):

		if body.has_method("take_damage"):

			body.take_damage(damage)

	queue_free()

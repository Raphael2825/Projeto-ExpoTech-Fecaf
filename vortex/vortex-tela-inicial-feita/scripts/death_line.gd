extends Marker2D

# Referências para os dois jogadores
@export var player1: CharacterBody2D
@export var player2: CharacterBody2D

func _ready() -> void:
	# Tenta buscar os jogadores automaticamente se você esquecer de arrastar no Inspetor
	if not player1 and has_node("../Player"):
		player1 = get_node("../Player")
	if not player2 and has_node("../Player2"):
		player2 = get_node("../Player2")

func _process(_delta: float) -> void:
	# Verifica o Player 1
	if is_instance_valid(player1):
		if player1.global_position.y > global_position.y:
			resetar_fase()
			
	# Verifica o Player 2
	if is_instance_valid(player2):
		if player2.global_position.y > global_position.y:
			resetar_fase()

func resetar_fase() -> void:
	# Reinicia a fase atual na qual os jogadores caíram
	get_tree().reload_current_scene()

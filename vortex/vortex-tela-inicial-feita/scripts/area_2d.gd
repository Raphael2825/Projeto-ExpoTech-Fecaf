extends Area2D

@export_file("*.tscn") var proxima_fase: String

# Lista para o modo cooperativo (se estiver usando a opção de os dois entrarem)
var jogadores_no_portal: Array[Node2D] = []

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

func _process(_delta: float) -> void:
	# DETECÇÃO DO TECLADO: Se apertar a tecla "F" no teclado
	if Input.is_key_pressed(KEY_F):
		mudar_de_fase()

func _on_body_entered(body: Node2D) -> void:
	# Verifica se quem entrou foi um dos players
	if (body.name == "Player" or body.name == "Player2") and not body in jogadores_no_portal:
		jogadores_no_portal.append(body)
		
		# Se os dois jogadores estiverem na área, passa de fase
		if jogadores_no_portal.size() == 2:
			mudar_de_fase()

func _on_body_exited(body: Node2D) -> void:
	if body in jogadores_no_portal:
		jogadores_no_portal.erase(body)

func mudar_de_fase() -> void:
	if proxima_fase != "":
		get_tree().change_scene_to_file(proxima_fase)
	else:
		print("Erro: Nenhuma cena foi definida no Inspetor!")

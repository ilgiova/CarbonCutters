extends CharacterBody2D

@export var movement_speed = 200.0
@export var damage = 10 # 🔴 Quantità di danno inflitto

@onready var player = get_tree().get_first_node_in_group("player")

func _physics_process(_delta):
	if player == null:
		player = get_tree().get_first_node_in_group("player")
		return

	var direction = global_position.direction_to(player.global_position)
	velocity = direction * movement_speed
	
	if velocity.x != 0:
		$Sprite2D.flip_h = velocity.x > 0
	
	move_and_slide()

# 🔴 Questa funzione deve essere collegata al segnale body_entered della Area2D
func _on_hitbox_body_entered(body: Node2D) -> void:
	# Controlliamo se l'oggetto colpito è il Player
	if body.is_in_group("player"):
		# 1. Infligge il danno chiamando la funzione sul player
		if body.has_method("take_damage"):
			body.take_damage(damage)
		
		# 2. Il nemico si autodistrugge
		explode()

func explode() -> void:
	# Qui in futuro potrai aggiungere particelle o suoni
	print("Il nemico è esploso colpendo il player!")
	queue_free() # Rimuove il nemico dalla scena

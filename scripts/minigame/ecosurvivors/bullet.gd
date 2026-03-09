extends Area2D

@export var damage = 15
@export var self_rotation_speed: float = 5.0
@export var damage_cooldown = 0.5

var hit_enemies = {}  # Dizionario: nemico -> true

func _process(delta: float) -> void:
	rotation += self_rotation_speed * delta

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("enemy") and not hit_enemies.has(body):
		if body.has_method("take_damage"):
			body.take_damage(damage)
		hit_enemies[body] = true
		# Dopo il cooldown rimuove SOLO quel nemico dal dizionario
		await get_tree().create_timer(damage_cooldown).timeout
		hit_enemies.erase(body)

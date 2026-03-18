extends Area2D

@export var damage: int = 15
@export var self_rotation_speed: float = 5.0
@export var damage_cooldown: float = 0.5

var _hit_enemies: Dictionary = {}

func _process(delta: float) -> void:
	rotation += self_rotation_speed * delta

func _on_body_entered(body: Node2D) -> void:
	if not body.is_in_group("enemy"):
		return
	if _hit_enemies.has(body):
		return
	if body.has_method("take_damage"):
		body.take_damage(damage)
	_hit_enemies[body] = true
	_start_cooldown(body)

func _start_cooldown(enemy: Node2D) -> void:
	await get_tree().create_timer(damage_cooldown).timeout
	if _hit_enemies.has(enemy):
		_hit_enemies.erase(enemy)

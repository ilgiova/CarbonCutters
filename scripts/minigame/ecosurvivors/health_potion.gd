extends Area2D

@export var heal_amount: int = 20
@export var attract_speed: float = 300.0

var target: Node2D = null

func _process(delta: float) -> void:
	if target != null:
		global_position = global_position.move_toward(target.global_position, attract_speed * delta)
		if global_position.distance_to(target.global_position) < 10.0:
			if target.has_method("heal"):
				target.heal(heal_amount)
			queue_free()

func attract(player: Node2D) -> void:
	target = player

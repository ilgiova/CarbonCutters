class_name BasePickup
extends Area2D

@export var attract_speed: float = 350.0

var _target: Node2D = null

func _process(delta: float) -> void:
	if not is_instance_valid(_target):
		if _target != null:
			_target = null
		return
	global_position = global_position.move_toward(_target.global_position, attract_speed * delta)
	if global_position.distance_to(_target.global_position) < 10.0:
		_on_collected(_target)
		queue_free()

func attract(player: Node2D) -> void:
	if not is_instance_valid(player):
		return
	if _target == null:
		_target = player

func _on_collected(_collector: Node2D) -> void:
	pass

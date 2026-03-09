extends Node2D

@export var rotation_speed: float = 1.5
@export var orbit_radius: float = 150.0

var initialized = false

func _process(delta: float) -> void:
	rotation += rotation_speed * delta
	
	if not initialized:
		for child in get_children():
			child.position = Vector2(orbit_radius, 0)
		initialized = true

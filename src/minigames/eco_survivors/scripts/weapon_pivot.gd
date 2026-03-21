extends Node2D

@export var rotation_speed: float = 3
@export var orbit_radius: float = 120.0

func _ready() -> void:
	reposition_bullets()

func _process(delta: float) -> void:
	rotation += rotation_speed * delta

func reposition_bullets() -> void:
	var bullets := get_children()
	var count := bullets.size()
	if count == 0:
		return
	for i in range(count):
		var angle := (TAU / float(count)) * i
		bullets[i].position = Vector2(cos(angle), sin(angle)) * orbit_radius

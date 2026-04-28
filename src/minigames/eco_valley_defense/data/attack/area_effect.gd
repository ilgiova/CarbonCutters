extends Node2D
class_name AreaEffect

# Raggio naturale dell'ultimo frame in pixel — modifica in base al tuo sprite!
const NATIVE_RADIUS: float = 75

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D

var _radius: float = 100.0
var _damage: float = 0.0
var _tower: Node = null
var _damage_dealt := false

func _ready() -> void:
	sprite.animation_finished.connect(_on_animation_finished)
	sprite.frame_changed.connect(_on_frame_changed)

func setup_area(radius: float, damage: float, tower: Node, color: Color = Color.WHITE) -> void:
	if not is_inside_tree():
		await ready
	
	sprite.modulate = color
	_radius = radius
	_damage = damage
	_tower = tower
	sprite.modulate = color
	
	# Scala lo sprite per coprire il range della torre
	var s = radius / NATIVE_RADIUS
	sprite.scale = Vector2(s, s)
	
	sprite.play("default")

func _on_frame_changed() -> void:
	# Applica il danno a metà animazione (frame centrale)
	var mid_frame = sprite.sprite_frames.get_frame_count("default") / 2
	if sprite.frame >= mid_frame and not _damage_dealt:
		_damage_dealt = true
		_apply_damage_to_enemies()

func _apply_damage_to_enemies() -> void:
	if not is_instance_valid(_tower):
		return
	# Recupera tutti i nemici nel range della torre
	for enemy in _tower.enemies_in_range:
		if is_instance_valid(enemy) and enemy.has_method("take_damage"):
			enemy.take_damage(_damage)

func _on_animation_finished() -> void:
	queue_free()

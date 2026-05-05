extends Node2D
class_name LaserBeam

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D

var _target: Node = null
var _damage: float = 0.0
var _tower_data: TowerData = null   # ← NUOVO
var _speed: float = 600.0
var _can_move := false

func _ready() -> void:
	sprite.animation_finished.connect(_on_animation_finished)

# Setup esteso con TowerData
func setup(from_global: Vector2, target: Node, damage: float, tower_data: TowerData = null, _color: Color = Color.WHITE) -> void:
	if not is_inside_tree():
		await ready
	
	global_position = from_global
	_target = target
	_damage = damage
	_tower_data = tower_data
	
	if is_instance_valid(_target):
		look_at(_target.global_position)
	
	sprite.play("default")

func _on_animation_finished() -> void:
	sprite.stop()
	sprite.frame = sprite.sprite_frames.get_frame_count("default") - 1
	_can_move = true

func _process(delta: float) -> void:
	if not _can_move:
		return
	if not is_instance_valid(_target):
		queue_free()
		return
	
	var direction = (_target.global_position - global_position).normalized()
	global_position += direction * _speed * delta
	look_at(_target.global_position)
	
	if global_position.distance_to(_target.global_position) < 16.0:
		_hit()

func _hit() -> void:
	if is_instance_valid(_target) and _target.has_method("take_damage"):
		# Danno diretto
		_target.take_damage(_damage)
		
		# Applica DOT se la torre lo prevede
		if _tower_data and _tower_data.attack_type == TowerData.AttackType.SINGLE_DOT:
			if _tower_data.dot_damage > 0 and _tower_data.dot_duration > 0:
				if _target.has_method("apply_status_effect"):
					var poison = StatusEffect.create_poison(
						_tower_data.dot_damage,
						_tower_data.dot_tick_interval,
						_tower_data.dot_duration
					)
					_target.apply_status_effect(poison)
	queue_free()

extends Node2D

@export var enemy_scene: PackedScene
@export var tank_scene: PackedScene
@export var spawn_radius: float = 1400.0
@export var enemy_spawn_interval: float = 1.0
@export var tank_spawn_interval: float = 5.0

@export var health_scale_per_level: float = 0.10
@export var damage_scale_per_level: float = 0.10
@export var speed_scale_per_level: float = 0.05
@export var max_enemy_speed: float = 270.0

@onready var player = get_tree().get_first_node_in_group("player")

var rng = RandomNumberGenerator.new()
var time_since_enemy: float = 0.0
var time_since_tank: float = 0.0

func _ready() -> void:
	rng.randomize()

func _process(delta: float) -> void:
	time_since_enemy += delta
	time_since_tank += delta
	
	if time_since_enemy >= enemy_spawn_interval:
		spawn(enemy_scene)
		time_since_enemy = 0.0
		
	if time_since_tank >= tank_spawn_interval:
		spawn(tank_scene)
		time_since_tank = 0.0

func spawn(scene: PackedScene) -> void:
	if scene == null or player == null:
		return
	var new_enemy = scene.instantiate()
	get_tree().current_scene.add_child(new_enemy)
	new_enemy.global_position = get_random_circumference_position()
	apply_scaling(new_enemy)

func apply_scaling(enemy: Node) -> void:
	var level = player.level if "level" in player else 1
	if level <= 1:
		return
	
	var multiplier = level - 1
	
	enemy.max_health = int(enemy.max_health * (1.0 + health_scale_per_level * multiplier))
	enemy.current_health = enemy.max_health
	
	enemy.damage = int(enemy.damage * (1.0 + damage_scale_per_level * multiplier))
	
	var new_speed = enemy.movement_speed * (1.0 + speed_scale_per_level * multiplier)
	enemy.movement_speed = minf(new_speed, max_enemy_speed)

func get_random_circumference_position() -> Vector2:
	var random_angle = rng.randf_range(0.0, TAU)
	var direction = Vector2.from_angle(random_angle)
	return player.global_position + (direction * spawn_radius)

extends Node2D

@export var enemy_scene: PackedScene
@export var tank_scene: PackedScene
@export var spawn_radius: float = 1000.0

# Tempi di spawn in secondi
@export var enemy_spawn_interval: float = 1.0
@export var tank_spawn_interval: float = 10.0

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
	var spawn_pos = get_random_circumference_position()
	get_tree().current_scene.add_child(new_enemy)
	new_enemy.global_position = spawn_pos

func get_random_circumference_position() -> Vector2:
	var random_angle = rng.randf_range(0.0, TAU)
	var direction = Vector2(cos(random_angle), sin(random_angle))
	return player.global_position + (direction * spawn_radius)

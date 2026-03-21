extends BaseEnemy

@export var tank_exp_scene: PackedScene
@export var tank_potion_scene: PackedScene

func _ready() -> void:
	movement_speed = 80.0
	max_health = 150
	damage = 40
	potion_drop_chance = 0.20
	exp_value = 5
	if tank_exp_scene:
		exp_scene = tank_exp_scene
	if tank_potion_scene:
		potion_scene = tank_potion_scene
	super._ready()

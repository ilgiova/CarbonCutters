extends CharacterBody2D

@export var movement_speed = 100.0
@export var damage = 40
@export var max_health: int = 150
@export var exp_scene: PackedScene
@export var potion_scene: PackedScene

var current_health: int

@onready var player = get_tree().get_first_node_in_group("player")

func _ready() -> void:
	add_to_group("enemy")
	current_health = max_health

func _physics_process(_delta):
	if player == null:
		player = get_tree().get_first_node_in_group("player")
		return
	var direction = global_position.direction_to(player.global_position)
	velocity = direction * movement_speed
	if velocity.x != 0:
		$Sprite2D.flip_h = velocity.x > 0
	move_and_slide()

func take_damage(amount: int) -> void:
	current_health -= amount
	flash_red()
	if current_health <= 0:
		die()

func flash_red() -> void:
	$Sprite2D.modulate = Color.RED
	await get_tree().create_timer(0.2).timeout
	$Sprite2D.modulate = Color.WHITE

func die() -> void:
	if exp_scene:
		var orb = exp_scene.instantiate()
		get_tree().current_scene.add_child(orb)
		orb.global_position = global_position
	if potion_scene and randf() < 0.01:
		var potion = potion_scene.instantiate()
		get_tree().current_scene.add_child(potion)
		potion.global_position = global_position
	queue_free()

func _on_hitbox_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		if body.has_method("take_damage"):
			body.take_damage(damage)
		explode()

func explode() -> void:
	queue_free()

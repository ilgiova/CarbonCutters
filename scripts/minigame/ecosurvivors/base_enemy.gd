class_name BaseEnemy
extends CharacterBody2D

@export_category("Stats")
@export var movement_speed: float = 200.0
@export var damage: int = 10
@export var max_health: int = 30
@export var exp_value: int = 1

@export_category("Drops")
@export var exp_scene: PackedScene
@export var potion_scene: PackedScene

var potion_drop_chance: float = 0.02
const FLASH_DURATION: float = 0.2
var current_health: int
var _player: Node2D = null

func _ready() -> void:
	add_to_group("enemy")
	current_health = max_health
	_player = get_tree().get_first_node_in_group("player")

func _physics_process(_delta: float) -> void:
	if not is_instance_valid(_player):
		_player = get_tree().get_first_node_in_group("player")
		if _player == null:
			push_error("[BaseEnemy:%s] Cannot find player" % name)
			return
	var direction := global_position.direction_to(_player.global_position)
	velocity = direction * movement_speed
	if velocity.x != 0.0:
		$Sprite2D.flip_h = velocity.x > 0.0
	move_and_slide()

func take_damage(amount: int) -> void:
	current_health = clampi(current_health - amount, 0, max_health)
	flash_red()
	if current_health <= 0:
		die()

func flash_red() -> void:
	var sprite := get_node_or_null("Sprite2D") as Sprite2D
	if sprite == null:
		return
	sprite.modulate = Color.RED
	await get_tree().create_timer(FLASH_DURATION).timeout
	if is_instance_valid(sprite):
		sprite.modulate = Color.WHITE

func die() -> void:
	PlayerData.add_score(5)
	call_deferred("_spawn_drops")
	queue_free()

func _spawn_drops() -> void:
	var scene_root := get_tree().current_scene
	if exp_scene:
		var orb := exp_scene.instantiate()
		scene_root.add_child(orb)
		orb.global_position = global_position
		if orb.has_method("set_exp_value"):
			orb.set_exp_value(exp_value)
	if potion_scene and randf() < potion_drop_chance:
		var potion := potion_scene.instantiate()
		scene_root.add_child(potion)
		potion.global_position = global_position

func _on_hitbox_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		if body.has_method("take_damage"):
			body.take_damage(damage)
		explode()

func explode() -> void:
	queue_free()

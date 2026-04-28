# enemy.gd
extends CharacterBody2D

signal enemy_died(reward: int)
signal reached_end(damage: int)

@onready var sprite: Sprite2D = $Sprite2D  # cambia se il nodo si chiama diversamente

var active_effects: Array[StatusEffect] = []
var data: EnemyData = null
var health: float = 0.0
var path_follow: PathFollow2D = null
var hp_multiplier: float = 1.0
var speed_multiplier: float = 1.0

func _ready() -> void:
	z_index = 10
	add_to_group("enemies")
	set_process(true)
	if data != null:
		_apply_data_internal()

func apply_data(d: EnemyData) -> void:
	data = d
	if is_inside_tree():
		_apply_data_internal()

func _apply_data_internal() -> void:
	health = data.max_hp * hp_multiplier
	if data.texture and sprite:
		sprite.texture = data.texture
	if sprite:
		sprite.scale = Vector2.ONE * data.scale_multiplier

func _process(delta: float) -> void:
	if path_follow == null or data == null:
		return
	
	# Calcola velocità con eventuali slow
	var current_speed_mult = speed_multiplier
	for effect in active_effects:
		if effect.type == StatusEffect.Type.SLOW:
			current_speed_mult *= (1.0 - effect.slow_amount)
	
	path_follow.progress += data.speed * current_speed_mult * delta
	global_position = path_follow.global_position
	
	# Aggiorna effetti attivi
	_process_effects(delta)
	
	if path_follow.progress_ratio >= 1.0:
		reached_end.emit(data.damage_to_castle)
		_cleanup()

## Chiamato dalle torri quando sparano
func take_damage(amount: float) -> void:
	if data == null:
		return
	health -= amount
	_flash_damage()
	if health <= 0:
		die()

func _flash_damage() -> void:
	if sprite == null:
		return
	sprite.modulate = Color(1, 0.3, 0.3)
	await get_tree().create_timer(0.1).timeout
	if is_instance_valid(sprite):
		sprite.modulate = Color.WHITE

func die() -> void:
	if data:
		enemy_died.emit(data.gold_reward)
		# Spawna i nemici di morte (per il boss)
		if data.death_spawn.size() > 0:
			_spawn_death_enemies()
	_cleanup()

func _spawn_death_enemies() -> void:
	# Scegli a caso quanti nemici spawnare (5-10)
	var count = randi_range(15, 25)
	
	# Per ogni spawn, scegli a caso un nemico dall'array death_spawn
	var enemies_to_spawn: Array[EnemyData] = []
	for i in count:
		var random_enemy = data.death_spawn[randi() % data.death_spawn.size()]
		enemies_to_spawn.append(random_enemy)
	
	var spawn_data = {
		"position": global_position,
		"path_progress": path_follow.progress if path_follow else 0.0,
		"enemies": enemies_to_spawn
	}
	
	var main = get_tree().current_scene
	if main.has_method("spawn_death_enemies"):
		main.spawn_death_enemies(spawn_data)

func apply_status_effect(effect: StatusEffect) -> void:
	# Se esiste già lo stesso tipo, sostituisci con quello nuovo (refresh)
	for i in range(active_effects.size() - 1, -1, -1):
		if active_effects[i].type == effect.type:
			active_effects.remove_at(i)
	active_effects.append(effect)
	_update_visual_tint()
	
func _process_effects(delta: float) -> void:
	for i in range(active_effects.size() - 1, -1, -1):
		var effect = active_effects[i]
		effect.duration_remaining -= delta
		
		# Tick di danno per veleno
		if effect.type == StatusEffect.Type.POISON:
			effect._tick_timer += delta
			if effect._tick_timer >= effect.tick_interval:
				effect._tick_timer = 0.0
				take_damage(effect.damage_per_tick)
		
		# Rimuovi se scaduto
		if effect.duration_remaining <= 0:
			active_effects.remove_at(i)
	
	_update_visual_tint()

func _update_visual_tint() -> void:
	if sprite == null:
		return
	if active_effects.is_empty():
		sprite.modulate = Color.WHITE
		return
	# Usa il colore dell'ultimo effetto applicato
	sprite.modulate = active_effects[active_effects.size() - 1].color_tint

func _cleanup() -> void:
	if path_follow:
		path_follow.queue_free()
	queue_free()

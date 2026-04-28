class_name WaveManager
extends Node

signal round_started(round_number: int)
signal round_completed(round_number: int)
signal wave_countdown(seconds_left: float)

enum State { IDLE, RESTING, SPAWNING, WAITING_FOR_KILLS }

@export var enemy_pool: Array[EnemyData] = []
@export var auto_start: bool = true
@export var initial_delay: float = 5.0

var current_round: int = 0
var state: State = State.IDLE
var _alive_enemies: int = 0
var _game: Node = null
var auto_continue: bool = false

func _ready() -> void:
	_game = get_parent()


func _spawn_wave(wave: WaveData) -> void:
	for entry in wave.entries:
		if entry.delay_before > 0:
			await get_tree().create_timer(entry.delay_before).timeout
		
		for i in entry.count:
			_spawn_one(entry.enemy_data)
			await get_tree().create_timer(wave.spawn_interval).timeout

func _spawn_one(enemy_data: EnemyData) -> void:
	if _game == null or not _game.has_method("spawn_enemy"):
		return
	_alive_enemies += 1
	
	# Calcola scaling: ogni 10 round +5% HP e +10% velocità
	var tier = current_round / 10  # 0 nei round 1-9, 1 nei round 10-19, ecc.
	var hp_mult = 1.0 + (tier * 0.12)
	var speed_mult = 1.0 + (tier * 0.10)
	
	_game.spawn_enemy(enemy_data, hp_mult, speed_mult)
	var enemies = get_tree().get_nodes_in_group("enemies")
	if enemies.size() > 0:
		var enemy = enemies[enemies.size() - 1]
		if not enemy.tree_exited.is_connected(_on_enemy_removed):
			enemy.tree_exited.connect(_on_enemy_removed)

func _on_enemy_removed() -> void:
	# Se stiamo uscendo dalla scena, ignora
	if not is_inside_tree():
		return
	
	_alive_enemies = max(0, _alive_enemies - 1)
	if state == State.WAITING_FOR_KILLS and _alive_enemies <= 0:
		_complete_round()

func _complete_round() -> void:
	if not is_inside_tree():
		return
	
	state = State.RESTING
	round_completed.emit(current_round)
	print("Round ", current_round, " completato!")
	
	if auto_continue:
		# Modalità auto: piccola pausa e poi parte da solo
		await get_tree().create_timer(1.0).timeout
		if is_inside_tree():
			start_next_round()

func request_next_round() -> void:
	print("request_next_round chiamato, stato attuale: ", state)
	if state == State.RESTING or state == State.IDLE:
		start_next_round()
	else:
		print("Stato non valido per partire")

func start_next_round() -> void:
	print("start_next_round!")
	current_round += 1
	state = State.SPAWNING
	round_started.emit(current_round)
	
	var wave = WaveGenerator.generate(current_round, enemy_pool)
	print("Wave generata con ", wave.entries.size(), " entries")
	for entry in wave.entries:
		print("  - ", entry.count, "x ", entry.enemy_data.enemy_name if entry.enemy_data else "NULL")
	
	await _spawn_wave(wave)
	state = State.WAITING_FOR_KILLS

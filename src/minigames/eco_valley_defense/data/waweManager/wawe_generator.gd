class_name WaveGenerator
extends RefCounted

static func generate(round_number: int, enemy_pool: Array[EnemyData]) -> WaveData:
	var wave = WaveData.new()
	wave.spawn_interval = max(0.2, 0.9 - round_number * 0.025)
	wave.rest_time = 7.0
	
	if enemy_pool.size() < 5:
		push_warning("WaveGenerator: serve un pool di 5 EnemyData")
		return wave
	
	var enemy1 = enemy_pool[0]
	var enemy2 = enemy_pool[1]
	var enemy3 = enemy_pool[2]
	var enemy4 = enemy_pool[3]
	var boss   = enemy_pool[4]
	
	# Round boss puro ogni 10 round
	if round_number > 0 and round_number % 10 == 0:
		_generate_boss_round(wave, round_number, boss, enemy1, enemy2)
		return wave
	
	# Round normali
	var base_count = 4 + int(round_number * 2.5)
	var variance = randf_range(0.8, 1.2)
	base_count = int(base_count * variance)
	
	# Tipo round in base al modulo 5
	match round_number % 5:
		0:
			_generate_swarm_round(wave, round_number, enemy1, enemy2, base_count)
		1:
			_generate_balanced_round(wave, round_number, enemy1, enemy2, enemy3, enemy4, base_count)
		2:
			_generate_tank_round(wave, round_number, enemy1, enemy3, base_count)
		3:
			_generate_speed_round(wave, round_number, enemy1, enemy4, base_count)
		4:
			_generate_balanced_round(wave, round_number, enemy1, enemy2, enemy3, enemy4, base_count)
	
	# Mini-boss casuale
	if round_number >= 13 and randf() < 0.15:
		var mini_boss = WaveEntry.new()
		mini_boss.enemy_data = boss
		mini_boss.count = 1
		mini_boss.delay_before = 4.0
		wave.entries.append(mini_boss)
	
	return wave


# ---------------------------------------------------------------------------
# Helper functions
# ---------------------------------------------------------------------------

static func _generate_balanced_round(wave: WaveData, round_number: int, enemy1: EnemyData, enemy2: EnemyData, enemy3: EnemyData, enemy4: EnemyData, base_count: int) -> void:
	var e1 = WaveEntry.new()
	e1.enemy_data = enemy1
	e1.count = base_count
	wave.entries.append(e1)
	
	if round_number >= 7:
		var e2 = WaveEntry.new()
		e2.enemy_data = enemy2
		e2.count = max(2, int(round_number / 3.5))
		wave.entries.append(e2)
	
	if round_number >= 15:
		var e3 = WaveEntry.new()
		e3.enemy_data = enemy3
		e3.count = max(1, int(round_number / 8.0))
		wave.entries.append(e3)
	
	if round_number >= 22:
		var e4 = WaveEntry.new()
		e4.enemy_data = enemy4
		e4.count = max(2, int(round_number / 6.0))
		wave.entries.append(e4)

# Tank round
static func _generate_tank_round(wave: WaveData, round_number: int, enemy1: EnemyData, enemy3: EnemyData, base_count: int) -> void:
	var e1 = WaveEntry.new()
	e1.enemy_data = enemy1
	e1.count = int(base_count * 0.6)
	wave.entries.append(e1)
	
	var min_round_for_tanks = max(7, 12 - int(round_number / 5.0))
	if round_number >= min_round_for_tanks:
		var e3 = WaveEntry.new()
		e3.enemy_data = enemy3
		e3.count = max(2, int(round_number / 5.5))
		wave.entries.append(e3)

# Speed round
static func _generate_speed_round(wave: WaveData, round_number: int, enemy1: EnemyData, enemy4: EnemyData, base_count: int) -> void:
	var e1 = WaveEntry.new()
	e1.enemy_data = enemy1
	e1.count = int(base_count * 0.7)
	wave.entries.append(e1)
	
	var min_round_for_speed = max(8, 18 - int(round_number / 4.0))
	if round_number >= min_round_for_speed:
		var e4 = WaveEntry.new()
		e4.enemy_data = enemy4
		e4.count = max(3, int(round_number / 4.0))
		wave.entries.append(e4)
		wave.spawn_interval *= 0.5

# Swarm round
static func _generate_swarm_round(wave: WaveData, round_number: int, enemy1: EnemyData, enemy2: EnemyData, base_count: int) -> void:
	var e1 = WaveEntry.new()
	e1.enemy_data = enemy1
	e1.count = int(base_count * 1.8)
	wave.entries.append(e1)
	
	if round_number >= 8:
		var e2 = WaveEntry.new()
		e2.enemy_data = enemy2
		e2.count = max(3, int(round_number / 4.0))
		wave.entries.append(e2)
	
	wave.spawn_interval *= 0.7

# Boss round
static func _generate_boss_round(wave: WaveData, round_number: int, boss: EnemyData, enemy1: EnemyData, enemy2: EnemyData) -> void:
	var minions = WaveEntry.new()
	minions.enemy_data = enemy1
	minions.count = 8 + int(round_number / 2.0)
	wave.entries.append(minions)
	
	if round_number >= 20:
		var support = WaveEntry.new()
		support.enemy_data = enemy2
		support.count = max(3, int(round_number / 5.0))
		wave.entries.append(support)
	
	# Boss arriva dopo l'ondata principale
	var b = WaveEntry.new()
	b.enemy_data = boss
	b.count = 1 + int(round_number / 25.0)
	b.delay_before = 4.0
	wave.entries.append(b)
	
	# Aftermath dopo il boss
	if round_number >= 30:
		var aftermath = WaveEntry.new()
		aftermath.enemy_data = enemy2
		aftermath.count = int(round_number / 4.0)
		aftermath.delay_before = 5.0
		wave.entries.append(aftermath)

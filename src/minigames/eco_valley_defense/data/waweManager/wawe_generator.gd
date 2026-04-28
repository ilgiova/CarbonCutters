class_name WaveGenerator
extends RefCounted

static func generate(round_number: int, enemy_pool: Array[EnemyData]) -> WaveData:
	var wave = WaveData.new()
	wave.spawn_interval = max(0.3, 1.0 - round_number * 0.02)
	wave.rest_time = 8.0
	
	if enemy_pool.size() < 5:
		push_warning("WaveGenerator: serve un pool di 5 EnemyData")
		return wave
	
	var enemy1 = enemy_pool[0]
	var enemy2 = enemy_pool[1]
	var enemy3 = enemy_pool[2]
	var enemy4 = enemy_pool[3]
	var boss   = enemy_pool[4]
	
	var base_count = 5 + round_number * 2
	
	var e1 = WaveEntry.new()
	e1.enemy_data = enemy1
	e1.count = base_count
	wave.entries.append(e1)
	
	if round_number >= 10:
		var e2 = WaveEntry.new()
		e2.enemy_data = enemy2
		e2.count = max(2, round_number / 5)
		e2.delay_before = 1.5
		wave.entries.append(e2)
	
	if round_number >= 20:
		var e3 = WaveEntry.new()
		e3.enemy_data = enemy3
		e3.count = max(1, round_number / 10)
		e3.delay_before = 2.0
		wave.entries.append(e3)
	
	if round_number >= 30:
		var e4 = WaveEntry.new()
		e4.enemy_data = enemy4
		e4.count = max(2, round_number / 8)
		e4.delay_before = 1.0
		wave.entries.append(e4)
	
	if round_number % 10 == 0 and round_number >= 10:
		var b = WaveEntry.new()
		b.enemy_data = boss
		b.count = 1 + (round_number / 20)
		b.delay_before = 3.0
		wave.entries.append(b)
	
	return wave

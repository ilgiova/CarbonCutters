class_name StatusEffect
extends RefCounted

enum Type { POISON, SLOW, BURN }

var type: Type
var damage_per_tick: float = 0.0
var tick_interval: float = 1.0
var duration_remaining: float = 0.0
var slow_amount: float = 0.0   # 0.3 = -30% velocità
var color_tint: Color = Color.WHITE

@warning_ignore("unused_private_class_variable")
var _tick_timer: float = 0.0

func _init(effect_type: Type, dur: float = 3.0) -> void:
	type = effect_type
	duration_remaining = dur

# Crea un veleno
static func create_poison(damage: float, tick: float, dur: float) -> StatusEffect:
	var e = StatusEffect.new(Type.POISON, dur)
	e.damage_per_tick = damage
	e.tick_interval = tick
	e.color_tint = Color(0.5, 1.0, 0.3)
	return e

# Crea uno slow
static func create_slow(amount: float, dur: float) -> StatusEffect:
	var e = StatusEffect.new(Type.SLOW, dur)
	e.slow_amount = amount
	e.color_tint = Color(0.7, 0.7, 1.0)
	return e

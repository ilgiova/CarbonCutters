extends Node2D

signal tower_clicked(tower: Node)

var data: TowerData = null
var _show_range := false

@onready var click_area:   Area2D           = $ClickArea
@onready var sprite:       Sprite2D         = $Sprite2D
@onready var range_area:   Area2D           = $RangeArea
@onready var range_shape:  CollisionShape2D = $RangeArea/CollisionShape2D
@onready var attack_timer: Timer            = $AttackTimer

var enemies_in_range: Array = []

func _ready() -> void:
	range_area.body_entered.connect(_on_enemy_entered)
	range_area.body_exited.connect(_on_enemy_exited)
	click_area.input_pickable = true
	attack_timer.timeout.connect(_on_attack_timer_timeout)
	if data != null:
		_apply_data_internal()

func apply_data(d: TowerData) -> void:
	data = d
	if is_inside_tree():
		_apply_data_internal()

func _apply_data_internal() -> void:
	if data.texture:
		sprite.texture = data.texture
		sprite.scale = Vector2(0.15, 0.15)
	var circle = CircleShape2D.new()
	circle.radius = data.attack_range
	range_shape.shape = circle
	attack_timer.wait_time = data.attack_cooldown
	attack_timer.start()
	queue_redraw()

func _on_click_area_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		tower_clicked.emit(self)
		get_viewport().set_input_as_handled()

func set_range_visible(value: bool) -> void:
	_show_range = value
	queue_redraw()

func _draw() -> void:
	if _show_range and data != null:
		draw_arc(Vector2.ZERO, data.attack_range, 0, TAU, 64, Color(1, 1, 0, 0.8), 5.0)

func set_preview_mode(enabled: bool) -> void:
	_show_range = enabled
	queue_redraw()

# ---------------------------------------------------------------------------
# Sistema di attacco
# ---------------------------------------------------------------------------

func _on_attack_timer_timeout() -> void:
	enemies_in_range = enemies_in_range.filter(func(e): return is_instance_valid(e))
	if enemies_in_range.is_empty():
		return
	
	match data.attack_type:
		TowerData.AttackType.SINGLE_TARGET:
			_attack_single()
		TowerData.AttackType.SINGLE_DOT:
			_attack_single()
		TowerData.AttackType.MULTI_LASER:
			_attack_multi_laser()
		TowerData.AttackType.AREA:
			_attack_area()
		TowerData.AttackType.AREA_SLOW:   
			_attack_area_slow()

func _attack_single() -> void:
	var target = enemies_in_range[0]
	_fire_effect_at(target)

func _attack_multi_laser() -> void:
	var targets = enemies_in_range.slice(0, data.num_targets)
	for target in targets:
		_fire_effect_at(target)

func _fire_effect_at(target: Node) -> void:
	if data.attack_effect_scene == null:
		return
	var effect = data.attack_effect_scene.instantiate()
	if effect.has_method("setup"):
		effect.setup(global_position, target, data.damage, data)
	get_tree().current_scene.add_child(effect)

func _attack_area() -> void:
	_spawn_area_effect()
	# Il danno viene applicato dall'effetto stesso

func _spawn_area_effect() -> void:
	if data.attack_effect_scene == null:
		return
	var effect = data.attack_effect_scene.instantiate()
	if effect.has_method("setup_area"):
		effect.setup_area(data.attack_range, data.damage, self, data.effect_color)
	get_tree().current_scene.add_child(effect)
	effect.global_position = global_position

func _deal_damage(target: Node, amount: float) -> void:
	if is_instance_valid(target) and target.has_method("take_damage"):
		target.take_damage(amount)

# ---------------------------------------------------------------------------
# Gestione nemici nel range
# ---------------------------------------------------------------------------

func _on_enemy_entered(body: Node) -> void:
	if body.is_in_group("enemies"):
		enemies_in_range.append(body)

func _on_enemy_exited(body: Node) -> void:
	enemies_in_range.erase(body)

# ---------------------------------------------------------------------------
# Upgrade
# ---------------------------------------------------------------------------

func try_upgrade(current_gold: int) -> bool:
	if data == null or data.upgrade == null:
		return false
	if current_gold < data.upgrade_cost:
		return false
	data = data.upgrade
	_apply_data_internal()
	return true

func get_upgrade_data() -> TowerData:
	if data == null:
		return null
	return data.upgrade

func _attack_area_slow() -> void:
	_spawn_area_effect()
	for target in enemies_in_range:
		# Danno area
		_deal_damage(target, data.damage)
		# Applica slow
		if data.slow_amount > 0 and data.slow_duration > 0:
			if target.has_method("apply_status_effect"):
				var slow = StatusEffect.create_slow(data.slow_amount, data.slow_duration)
				target.apply_status_effect(slow)

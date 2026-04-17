extends CharacterBody2D

enum State { IDLE, RUN }

@export_category("Stats")
@export var speed: int = 300
@export var max_health: int = 100

@export_category("Scenes")
@export var bullet_scene: PackedScene

var experience: int = 0
var current_health: int
var xp_to_levelup: int = 10
var level: int = 1
var current_rotation_speed: float = 2.0
var state: State = State.IDLE
var move_direction: Vector2 = Vector2.ZERO
var _level_up_screen: Node = null

@onready var animation_tree: AnimationTree = $AnimationTree
@onready var animation_playback: AnimationNodeStateMachinePlayback = \
	animation_tree.get("parameters/playback")
@onready var dust = $dust
@onready var health_bar = $HealtBar
@onready var weapon_pivot: Node2D = $WeaponPivot

@onready var stats_label = get_tree().get_first_node_in_group("stats_label")
@onready var exp_value_label: Label = $"../../HUD/MarginContainer/VBoxContainer/expLabelValue"
@onready var hp_label: Label = $"../../HUD/MarginContainer/VBoxContainer/Hp"
@onready var dmg_label: Label = $"../../HUD/MarginContainer/VBoxContainer/Dmg"
@onready var rotation_speed_label: Label = $"../../HUD/MarginContainer/VBoxContainer/RotationSpeedValue"

func _ready() -> void:
	add_to_group("player")
	animation_tree.active = true
	if dust != null:
		dust.emitting = false
	current_health = max_health
	_update_health_bar()
	if weapon_pivot != null:
		weapon_pivot.reposition_bullets()
		weapon_pivot.rotation_speed = current_rotation_speed
	update_stats_label()

func _physics_process(_delta: float) -> void:
	_movement_loop()

func _process(_delta: float) -> void:
	pass

func gain_exp(amount: int) -> void:
	experience += amount
	_update_exp_label()
	if experience >= xp_to_levelup:
		experience -= xp_to_levelup
		level += 1
		xp_to_levelup = 10 + level * 5
		_level_up()

func _update_exp_label() -> void:
	if exp_value_label != null:
		exp_value_label.text =  "%d / %d" % [experience, xp_to_levelup]

func _level_up() -> void:
	if _level_up_screen == null:
		_level_up_screen = get_tree().current_scene.get_node_or_null("LevelUpScreen")
	if _level_up_screen == null:
		return
	if _level_up_screen.answer_selected.is_connected(_on_answer_selected):
		_level_up_screen.answer_selected.disconnect(_on_answer_selected)
	_level_up_screen.answer_selected.connect(_on_answer_selected, CONNECT_ONE_SHOT)
	_level_up_screen.show_random_question()

func _on_answer_selected(_correct: bool) -> void:
	pass

func apply_powerup(id: String) -> void:
	match id:
		"damage":
			if weapon_pivot == null:
				return
			for bullet in weapon_pivot.get_children():
				bullet.damage += 15
		"health":
			max_health += 20
			current_health = mini(current_health + 20, max_health)
			_update_health_bar()
		"rotation":
			if weapon_pivot == null:
				return
			current_rotation_speed += 0.5
			weapon_pivot.rotation_speed = current_rotation_speed
		"bullet":
			_add_bullet()
	update_stats_label()

func _add_bullet() -> void:
	if bullet_scene == null or weapon_pivot == null:
		return
	var new_bullet := bullet_scene.instantiate()
	weapon_pivot.add_child(new_bullet)
	weapon_pivot.reposition_bullets()

func _update_health_bar() -> void:
	if health_bar != null:
		health_bar.max_value = max_health
		health_bar.value = current_health

func heal(amount: int) -> void:
	current_health = mini(current_health + amount, max_health)
	_update_health_bar()
	update_stats_label()

func take_damage(amount: int) -> void:
	current_health = clampi(current_health - amount, 0, max_health)
	_update_health_bar()
	update_stats_label()
	if current_health <= 0:
		_die()

func _die() -> void:
	var scene_resource = preload("res://src/minigames/eco_survivors/scenes/outro_screen.tscn")
	var instance = scene_resource.instantiate() as OutroScreen

	if instance == null:
		push_error("OutroScreen: il nodo radice della scena non è di tipo OutroScreen!")
		queue_free()
		return

	# Assegna PRIMA di add_child
	instance.points_get_from_other_scene_i_hate_my_life = level

	# Aggiungi alla scena
	get_tree().root.add_child(instance)
	
	# Distruggi il player (una volta sola!)
	queue_free()

	# Assegna PRIMA di add_child, così _ready() trova già il valore
	instance.points_get_from_other_scene_i_hate_my_life = level

	get_tree().root.add_child(instance)
	queue_free()
	scene_resource = preload("res://src/minigames/eco_survivors/scenes/outro_screen.tscn")
	instance = scene_resource.instantiate()
	
	# Usiamo il casting dinamico
	if instance is OutroScreen:
		instance.points_get_from_other_scene_i_hate_my_life = level
		get_tree().root.add_child(instance)
	else:
		# Questo accade se lo script non è sulla Root della scena o manca class_name
		get_tree().root.add_child(instance) 
		push_error("Attenzione: Lo script OutroScreen non è stato trovato sulla radice della scena!")
	
	queue_free()
	
func update_stats_label() -> void:
	if stats_label == null:
		return
	var bullet_damage = 0
	if weapon_pivot and weapon_pivot.get_child_count() > 0:
		bullet_damage = weapon_pivot.get_child(0).damage
		hp_label.text = "HP: %d / %d" % [current_health, max_health]
		dmg_label.text = tr("DAMAGE")+": %.1f" % [bullet_damage]
		rotation_speed_label.text = tr("SPEED")+": " + str(current_rotation_speed)
	

func _movement_loop() -> void:
	move_direction.x = float(Input.is_action_pressed("right")) - float(Input.is_action_pressed("left"))
	move_direction.y = float(Input.is_action_pressed("down")) - float(Input.is_action_pressed("up"))
	velocity = move_direction.normalized() * speed
	move_and_slide()
	var moving := velocity != Vector2.ZERO
	state = State.RUN if moving else State.IDLE
	_update_animation()
	if dust != null:
		dust.emitting = moving

func _update_animation() -> void:
	match state:
		State.IDLE:
			animation_playback.travel("idle")
		State.RUN:
			if abs(move_direction.x) > abs(move_direction.y):
				animation_playback.travel("run_right" if move_direction.x > 0.0 else "run_left")
			else:
				animation_playback.travel("run_down" if move_direction.y > 0.0 else "run_up")

func _on_pickup_radius_body_entered(_body: Node2D) -> void:
	pass

extends CharacterBody2D

enum State { IDLE, RUN }

@export_category("Stats")
@export var speed: int = 300
@export var max_health: int = 100
@export var bullet_scene: PackedScene
@export var orbit_radius: float = 80.0

var experience: int = 0
var current_health: int
var xp_to_levelup: int = 10
var level: int = 1
var level_up_screen: Node = null
var state: State = State.IDLE
var move_direction: Vector2 = Vector2.ZERO

@onready var animation_tree: AnimationTree = $AnimationTree
@onready var animation_playback: AnimationNodeStateMachinePlayback = animation_tree.get("parameters/playback")
@onready var dust = $dust
@onready var health_bar = $HealtBar
@onready var weapon_pivot = $WeaponPivot
@onready var exp_label = get_tree().get_first_node_in_group("exp_label")

func _ready() -> void:
	animation_tree.active = true
	if dust != null:
		dust.emitting = false
	current_health = max_health
	if health_bar != null:
		health_bar.max_value = max_health
		health_bar.value = current_health
	reposition_bullets()

func _physics_process(_delta: float) -> void:
	movement_loop()

func _process(delta: float) -> void:
	if weapon_pivot != null:
		var rot_speed = weapon_pivot.get_meta("rotation_speed", 2.0)
		weapon_pivot.rotation += rot_speed * delta

# ---- XP e Level Up ----

func gain_exp(amount: int) -> void:
	experience += amount
	update_exp_label()
	if experience >= xp_to_levelup:
		experience -= xp_to_levelup
		level += 1
		xp_to_levelup = 10 + level * 5
		level_up()

func update_exp_label() -> void:
	if exp_label != null:
		exp_label.text = "Garbage collected: " + str(experience) + " / " + str(xp_to_levelup)

func level_up() -> void:
	if level_up_screen == null:
		level_up_screen = get_tree().current_scene.get_node_or_null("LevelUpScreen")
	if level_up_screen == null:
		print("ERRORE: LevelUpScreen non trovato nella scena!")
		return
	if level_up_screen.answer_selected.is_connected(_on_answer_selected):
		level_up_screen.answer_selected.disconnect(_on_answer_selected)
	level_up_screen.show_random_question()
	level_up_screen.answer_selected.connect(_on_answer_selected, CONNECT_ONE_SHOT)

func _on_answer_selected(correct: bool) -> void:
	pass

func apply_powerup(id: String) -> void:
	match id:
		"damage":
			for bullet in weapon_pivot.get_children():
				bullet.damage += 5
		"health":
			max_health += 20
			current_health = mini(current_health + 20, max_health)
			if health_bar:
				health_bar.max_value = max_health
				health_bar.value = current_health
		"rotation":
			weapon_pivot.set_meta("rotation_speed", weapon_pivot.get_meta("rotation_speed", 2.0) + 0.5)
		"bullet":
			add_bullet()

func add_bullet() -> void:
	if bullet_scene == null:
		print("ERRORE: bullet_scene non assegnata nell'Inspector!")
		return
	var new_bullet = bullet_scene.instantiate()
	weapon_pivot.add_child(new_bullet)
	reposition_bullets()

func reposition_bullets() -> void:
	var bullets = weapon_pivot.get_children()
	var count = bullets.size()
	if count == 0:
		return
	for i in range(count):
		var angle = (TAU / count) * i
		bullets[i].position = Vector2(cos(angle), sin(angle)) * orbit_radius

# ---- Salute ----

func heal(amount: int) -> void:
	current_health = mini(current_health + amount, max_health)
	if health_bar != null:
		health_bar.value = current_health

func take_damage(amount: int) -> void:
	current_health -= amount
	current_health = clampi(current_health, 0, max_health)
	if health_bar != null:
		health_bar.value = current_health
	if current_health <= 0:
		die()

func die() -> void:
	get_tree().reload_current_scene()

# ---- Movimento ----

func movement_loop() -> void:
	move_direction.x = int(Input.is_action_pressed("right")) - int(Input.is_action_pressed("left"))
	move_direction.y = int(Input.is_action_pressed("down")) - int(Input.is_action_pressed("up"))
	var motion: Vector2 = move_direction.normalized() * speed
	velocity = motion
	move_and_slide()
	var moving := motion != Vector2.ZERO
	if moving:
		state = State.RUN
	else:
		state = State.IDLE
	update_animation()
	if dust != null:
		dust.emitting = moving

func update_animation() -> void:
	match state:
		State.IDLE:
			animation_playback.travel("idle")
		State.RUN:
			if abs(move_direction.x) > abs(move_direction.y):
				if move_direction.x < 0:
					animation_playback.travel("run_left")
				else:
					animation_playback.travel("run_right")
			else:
				if move_direction.y < 0:
					animation_playback.travel("run_up")
				else:
					animation_playback.travel("run_down")

func _on_pickup_radius_body_entered(body: Node2D) -> void:
	pass

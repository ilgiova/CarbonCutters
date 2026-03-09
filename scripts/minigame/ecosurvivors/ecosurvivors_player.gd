extends CharacterBody2D

enum State { IDLE, RUN }

@export_category("Stats")
@export var speed: int = 300
# 🔴 Nuove stats per la salute
@export var max_health: int = 100
var experience: int = 0
var current_health: int

var state: State = State.IDLE
var move_direction: Vector2 = Vector2.ZERO

@onready var animation_tree: AnimationTree = $AnimationTree
@onready var animation_playback: AnimationNodeStateMachinePlayback = animation_tree.get("parameters/playback")
@onready var dust = $dust
# 🔴 Riferimento alla barra (Assicurati che il nome nel Scene Tree sia "HealtBar")
@onready var health_bar = $HealtBar 
@onready var exp_label = get_tree().get_first_node_in_group("exp_label")

func _ready() -> void:
	animation_tree.active = true
	if dust != null:
		dust.emitting = false
	
	# 🔴 Inizializzazione salute
	current_health = max_health
	if health_bar != null:
		health_bar.max_value = max_health
		health_bar.value = current_health

func _physics_process(delta: float) -> void:
	movement_loop()

func gain_exp(amount: int) -> void:
	experience += amount
	update_exp_label()

func update_exp_label() -> void:
	if exp_label != null:
		exp_label.text = "Garbage collected: " + str(experience)

func heal(amount: int) -> void:
	current_health = mini(current_health + amount, max_health)
	if health_bar != null:
		health_bar.value = current_health

# 🔴 Funzione per ricevere danno
func take_damage(amount: int) -> void:
	current_health -= amount
	current_health = clampi(current_health, 0, max_health)
	
	if health_bar != null:
		health_bar.value = current_health
	
	if current_health <= 0:
		die()

# 🔴 Funzione per la morte
func die() -> void:
	# Per ora riavviamo, in futuro potrai mettere un'animazione di morte
	get_tree().reload_current_scene()

func movement_loop() -> void:
	# ... (il tuo codice di movimento rimane invariato) ...
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
	# ... (il tuo codice di animazione rimane invariato) ...
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
	pass # Replace with function body.

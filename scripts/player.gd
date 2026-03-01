extends CharacterBody2D

enum State { IDLE, RUN }

@export_category("Stats")
@export var speed: int = 300

var state: State = State.IDLE
var move_direction: Vector2 = Vector2.ZERO

@onready var animation_tree: AnimationTree = $AnimationTree
@onready var animation_playback: AnimationNodeStateMachinePlayback = animation_tree.get("parameters/playback")

# ✅ Metti qui il riferimento alle particelle
@onready var dust = $dust

func _ready() -> void:
	animation_tree.active = true
	if dust != null:
		dust.emitting = false

func _physics_process(delta: float) -> void:
	movement_loop()

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

	# ✅ accendi/spegni polvere solo se il nodo esiste
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

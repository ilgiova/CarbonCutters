extends CharacterBody2D

@onready var anim: AnimatedSprite2D = $Spritesheep
@onready var timer: Timer = $TimerSheep

enum {
	IDLE,
	NEW_DIR,
	MOVE
}

const SPEED := 30.0
const MAX_DIST := 10.0 * 64.0  
var current_state = IDLE
var is_roaming := true
var dir: Vector2 = Vector2.RIGHT
var start_pos: Vector2

func _ready() -> void:
	randomize()
	start_pos = global_position
	anim.play("idle")
	timer.start()

func _process(delta: float) -> void:
	if !is_roaming:
		anim.play("idle")
		return

	# Animazioni (adatta i nomi alle tue!)
	if current_state == MOVE:
		if dir.x < 0:
			anim.play("move")
			anim.flip_h = true
		elif dir.x > 0:
			anim.play("move")
			anim.flip_h = false
		elif dir.y < 0:
			anim.play("move")
			anim.flip_h = true
		elif dir.y > 0:
			anim.play("move")
			anim.flip_h = false
	else:
		anim.play("idle")

	# Stato
	match current_state:
		IDLE:
			pass
		NEW_DIR:
			dir = choose_dir()
		MOVE:
			move_roam(delta)

func choose_dir() -> Vector2:
	var dirs = [Vector2.RIGHT, Vector2.LEFT, Vector2.DOWN, Vector2.UP]
	return dirs[randi() % dirs.size()]

func move_roam(delta: float) -> void:
	var next_pos = global_position + dir * SPEED * delta
	if next_pos.distance_to(start_pos) > MAX_DIST:
		current_state = NEW_DIR
		return

	global_position = next_pos




func _on_timer_sheep_timeout() -> void:
	timer.wait_time = [0.5, 1.0, 1.5][randi() % 3]
	current_state = [IDLE, NEW_DIR, MOVE][randi() % 3]
	if current_state == MOVE:
		dir = choose_dir()

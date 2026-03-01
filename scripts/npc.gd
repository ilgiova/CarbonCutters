extends CharacterBody2D

@onready var icon: AnimatedSprite2D = $IconKeyboard
@onready var anim: AnimatedSprite2D = $AnimatedSprite2D

@export var npc_name: String = "NPC"
@export var npc_frames: SpriteFrames
@export_file("*.json") var dialogue_file

enum {
	IDLE,
	NEW_DIR,
	MOVE
}

const SPEED = 30
const TILE_SIZE = 64
const MAX_TILES = 10
const MAX_DIST = TILE_SIZE * MAX_TILES

var current_state = IDLE

var is_roaming = true
var is_chatting = false

var player
var player_in_chat_zone = false

var dir = Vector2.RIGHT
var start_pos


func _ready():
	randomize()
	icon.stop()
	icon.visible = false
	start_pos = position
	if npc_frames:
		anim.sprite_frames = npc_frames
	$Timer.start()


func _process(delta: float) -> void:
	if Input.is_action_just_pressed("interact") and player_in_chat_zone:
		$Dialogue.d_file = dialogue_file
		$Dialogue.start()
		is_chatting = true
		is_roaming = false
		anim.play("idle")
		return

	if is_chatting or !is_roaming:
		anim.play("idle")
		icon.stop()
		icon.visible = false
		return

	if current_state == IDLE or current_state == NEW_DIR:
		anim.play("idle")
	elif current_state == MOVE:
		if dir.x == -1:
			anim.play("run_left")
		elif dir.x == 1:
			anim.play("run_right")
		elif dir.y == -1:
			anim.play("run_up")
		elif dir.y == 1:
			anim.play("run_down")

	if is_roaming:
		match current_state:
			IDLE:
				pass
			NEW_DIR:
				dir = choose([
					Vector2.RIGHT,
					Vector2.LEFT,
					Vector2.DOWN,
					Vector2.UP
				])
			MOVE:
				move(delta)



func choose(array):
	array.shuffle()
	return array.front()



func move(delta):
	var next_pos = position + dir * delta * SPEED
	if next_pos.distance_to(start_pos) > MAX_DIST:
		current_state = NEW_DIR
		dir = choose([
			Vector2.RIGHT,
			Vector2.LEFT,
			Vector2.DOWN,
			Vector2.UP
		])
		return
	position = next_pos



func _on_timer_timeout():
	$Timer.wait_time = choose([1.0, 0.5, 1.5])
	current_state = choose([IDLE, NEW_DIR, MOVE])
	if current_state == MOVE:
		dir = choose([
			Vector2.RIGHT,
			Vector2.LEFT,
			Vector2.DOWN,
			Vector2.UP
		])



func _on_dialogue_dialogue_finish():
	is_chatting = false
	is_roaming = true



func _on_collision_area_body_shape_entered(body_rid, body, body_shape_index, local_shape_index):
	if body.is_in_group("player") or body.name.to_lower().find("player") != -1:
		player = body
		icon.play("default")
		icon.visible = true
		player_in_chat_zone = true



func _on_collision_area_body_shape_exited(body_rid, body, body_shape_index, local_shape_index):
	if body == player:
		icon.visible = false
		icon.stop()
		player_in_chat_zone = false
		player = null

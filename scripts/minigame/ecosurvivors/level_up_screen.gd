extends CanvasLayer

signal answer_selected(correct: bool)

var correct_index: int = -1
var available_powerups = []
var is_showing: bool = false

const QUESTIONS = [
	{
		"text": "Press B",
		"answers": ["A", "B", "C", "D"],
		"correct_index": 1
	},
	{
		"text": "Press D",
		"answers": ["A", "B", "C", "D"],
		"correct_index": 3
	},
]

const POWERUPS = [
	{"id": "damage", "label": "Bullet damage"},
	{"id": "health", "label": "Max health"},
	{"id": "rotation", "label": "Rotation Speed"},
	{"id": "bullet", "label": "Orbital Bullet"},
]

@onready var question_panel = $Panel
@onready var powerup_panel = $powerupPannel
@onready var question_label = $Panel/VBox/QuestionLabel
@onready var q_buttons = [
	$Panel/VBox/Button0,
	$Panel/VBox/Button1,
	$Panel/VBox/Button2,
	$Panel/VBox/Button3
]
@onready var powerup_buttons = [
	$powerupPannel/VBox/powerupButton0,
	$powerupPannel/VBox/powerupButton1,
	$powerupPannel/VBox/powerupButton2,
]

func _ready() -> void:
	add_to_group("level_up_screen")
	visible = false

func show_random_question() -> void:
	if is_showing:
		return
	is_showing = true
	get_tree().paused = true
	visible = true
	question_panel.visible = true
	powerup_panel.visible = false
	
	var q = QUESTIONS[randi() % QUESTIONS.size()]
	question_label.text = q.text
	correct_index = q.correct_index
	for i in range(q_buttons.size()):
		q_buttons[i].text = q.answers[i]
		q_buttons[i].pressed.connect(func(): _on_answer(i), CONNECT_ONE_SHOT)

func _on_answer(index: int) -> void:
	var correct = index == correct_index
	if correct:
		show_powerup_choice()
	else:
		is_showing = false
		get_tree().paused = false
		visible = false
		emit_signal("answer_selected", false)

func show_powerup_choice() -> void:
	question_panel.visible = false
	powerup_panel.visible = true
	
	var shuffled = POWERUPS.duplicate()
	shuffled.shuffle()
	available_powerups = shuffled.slice(0, 3)
	
	for i in range(powerup_buttons.size()):
		powerup_buttons[i].text = available_powerups[i].label
		var idx = i
		powerup_buttons[i].pressed.connect(func(): _on_powerup_selected(idx), CONNECT_ONE_SHOT)

func _on_powerup_selected(index: int) -> void:
	is_showing = false
	get_tree().paused = false
	visible = false
	
	# Disconnetti tutti i bottoni rimasti
	for btn in powerup_buttons:
		for connection in btn.pressed.get_connections():
			btn.pressed.disconnect(connection.callable)
	
	var p = get_tree().get_first_node_in_group("player")
	if p and p.has_method("apply_powerup"):
		p.apply_powerup(available_powerups[index].id)
	emit_signal("answer_selected", true)

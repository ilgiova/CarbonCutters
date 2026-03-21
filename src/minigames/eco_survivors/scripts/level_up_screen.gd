extends CanvasLayer

signal answer_selected(correct: bool)

var correct_index: int = -1
var available_powerups: Array = []
var is_showing: bool = false

const QUESTIONS: Array = [
  {
	"text": "How long does it take for a plastic bottle to decompose?",
	"answers": ["1 day", "1 year", "500 years", "1000 years"],
	"correct_index": 2
  },
  {
	"text": "Which bin should you use to recycle glass bottles?",
	"answers": ["General waste (black)", "Recycling (blue/green)", "Compost (brown)", "Hazardous waste"],
	"correct_index": 1
  },
  {
	"text": "How many times can aluminium be recycled?",
	"answers": ["Only once", "Up to 5 times", "Up to 10 times", "Indefinitely"],
	"correct_index": 3
  },
  {
	"text": "What percentage of a recycled glass bottle is used to make a new one?",
	"answers": ["10%", "40%", "70%", "100%"],
	"correct_index": 3
  },
  {
	"text": "Which of these items should NOT go in the recycling bin?",
	"answers": ["Cardboard box", "Plastic bottle", "Greasy pizza box", "Newspaper"],
	"correct_index": 2
  },
  {
	"text": "How long does it take for a glass bottle to decompose in a landfill?",
	"answers": ["10 years", "100 years", "500 years", "1 million years"],
	"correct_index": 3
  },
  {
	"text": "What does the recycling symbol with a number inside mean on plastic?",
	"answers": ["The product price", "The type of plastic resin", "How many times it was recycled", "The weight of the item"],
	"correct_index": 1
  },
  {
	"text": "Which material takes the longest to decompose?",
	"answers": ["Paper", "Cotton", "Glass", "Banana peel"],
	"correct_index": 2
  },
  {
	"text": "How much energy is saved by recycling one aluminium can compared to making a new one?",
	"answers": ["5%", "25%", "50%", "95%"],
	"correct_index": 3
  },
  {
	"text": "What should you do with plastic bags?",
	"answers": ["Put them in the recycling bin", "Throw them in general waste", "Return them to supermarket collection points", "Burn them"],
	"correct_index": 2
  },
]

const POWERUPS: Array = [
	{"id": "damage",   "label": "Bullet Damage"},
	{"id": "health",   "label": "Max Health"},
	{"id": "rotation", "label": "Rotation Speed"},
	{"id": "bullet",   "label": "Orbital Bullet"},
]

@onready var question_panel: Panel = $Panel
@onready var powerup_panel: Panel = $powerupPannel
@onready var question_label: Label = $Panel/VBox/QuestionLabel
@onready var q_buttons: Array = [
	$Panel/VBox/Button0,
	$Panel/VBox/Button1,
	$Panel/VBox/Button2,
	$Panel/VBox/Button3,
]
@onready var powerup_buttons: Array = [
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

	var q: Dictionary = QUESTIONS[randi() % QUESTIONS.size()]
	question_label.text = q.text
	correct_index = q.correct_index

	_disconnect_question_buttons()

	for i in range(q_buttons.size()):
		q_buttons[i].text = q.answers[i]
		var captured_i := i
		q_buttons[i].pressed.connect(func(): _on_answer(captured_i), CONNECT_ONE_SHOT)

func _on_answer(index: int) -> void:
	var correct := index == correct_index
	if correct:
		show_powerup_choice()
	else:
		_close()
		answer_selected.emit(false)

func show_powerup_choice() -> void:
	question_panel.visible = false
	powerup_panel.visible = true

	var shuffled: Array = POWERUPS.duplicate()
	shuffled.shuffle()
	available_powerups = shuffled.slice(0, 3)

	for i in range(powerup_buttons.size()):
		powerup_buttons[i].text = available_powerups[i].label
		var captured_i := i
		powerup_buttons[i].pressed.connect(
			func(): _on_powerup_selected(captured_i), CONNECT_ONE_SHOT
		)

func _on_powerup_selected(index: int) -> void:
	_close()
	_disconnect_powerup_buttons()

	var player: Node = get_tree().get_first_node_in_group("player")
	if player == null:
		push_error("[LevelUpScreen] _on_powerup_selected | player not found in group 'player'!")
		answer_selected.emit(true)
		return
	if player.has_method("apply_powerup"):
		player.apply_powerup(available_powerups[index].id)
	else:
		push_error("[LevelUpScreen] _on_powerup_selected | player has no 'apply_powerup' method")
	answer_selected.emit(true)

func _close() -> void:
	is_showing = false
	get_tree().paused = false
	visible = false

func _disconnect_question_buttons() -> void:
	for btn in q_buttons:
		for connection in btn.pressed.get_connections():
			btn.pressed.disconnect(connection.callable)

func _disconnect_powerup_buttons() -> void:
	for btn in powerup_buttons:
		for connection in btn.pressed.get_connections():
			btn.pressed.disconnect(connection.callable)

extends CanvasLayer

signal answer_selected(correct: bool)

var correct_index: int = -1
var available_powerups: Array = []
var is_showing: bool = false
var questions: Array = []

@export_file("*.json") var questions_file_en: String = "res://src/minigames/eco_survivors/question/Question_en.json"
@export_file("*.json") var questions_file_it: String = "res://src/minigames/eco_survivors/question/Question_it.json"

const POWERUPS: Array = [
	{"id": "damage",   "label_key": "POWERUP_BULLET_DAMAGE"},
	{"id": "health",   "label_key": "POWERUP_MAX_HEALTH"},
	{"id": "rotation", "label_key": "POWERUP_ROTATION_SPEED"},
	{"id": "bullet",   "label_key": "POWERUP_ORBITAL_BULLET"}
]
@export var answer_idle_texture: Texture2D
@export var answer_hover_texture: Texture2D
@export var answer_pressed_texture: Texture2D
@export var answer_correct_texture: Texture2D
@export var answer_wrong_texture: Texture2D

@onready var question_panel: Panel = $Panel
@onready var powerup_panel: Panel = $powerupPannel
@onready var question_label: Label = $Panel/VBox/QuestionLabel

@onready var q_buttons: Array[TextureButton] = [
	$Panel/VBox/Button1/TextureButton,
	$Panel/VBox/Button2/TextureButton,
	$Panel/VBox/Button3/TextureButton,
	$Panel/VBox/Button4/TextureButton
]

@onready var q_labels: Array[Label] = [
	$Panel/VBox/Button1/Label,
	$Panel/VBox/Button2/Label,
	$Panel/VBox/Button3/Label,
	$Panel/VBox/Button4/Label
]

@onready var powerup_buttons: Array[TextureButton] = [
	$powerupPannel/VBox/powerupButton1/TextureButton,
	$powerupPannel/VBox/powerupButton2/TextureButton,
	$powerupPannel/VBox/powerupButton3/TextureButton
]

@onready var powerup_labels: Array[Label] = [
	$powerupPannel/VBox/powerupButton1/Label,
	$powerupPannel/VBox/powerupButton2/Label,
	$powerupPannel/VBox/powerupButton3/Label
]

func _ready() -> void:
	add_to_group("level_up_screen")
	visible = false
	_load_questions()
	_setup_answer_buttons()



func _load_questions() -> void:
	questions.clear()

	var current_locale := TranslationServer.get_locale()
	var selected_file: String = ""

	if current_locale.begins_with("en"):
		selected_file = questions_file_en
	elif current_locale.begins_with("it"):
		selected_file = questions_file_it
	else:
		selected_file = questions_file_en

	if selected_file.is_empty():
		return

	if not FileAccess.file_exists(selected_file):
		return

	var file := FileAccess.open(selected_file, FileAccess.READ)
	if file == null:
		return

	var content := file.get_as_text()
	var parsed = JSON.parse_string(content)

	if parsed == null:
		return

	if parsed is not Array:
		return

	for item in parsed:
		if item is Dictionary:
			if item.has("text") and item.has("answers") and item.has("correct_index"):
				if item["answers"] is Array and item["answers"].size() == 4:
					questions.append(item)
				
func _setup_answer_buttons() -> void:
	for btn in q_buttons:
		btn.texture_normal = answer_idle_texture
		btn.texture_hover = answer_hover_texture
		btn.texture_pressed = answer_pressed_texture
		btn.ignore_texture_size = true
		btn.stretch_mode = TextureButton.STRETCH_SCALE

	for btn in powerup_buttons:
		btn.texture_normal = answer_idle_texture
		btn.texture_hover = answer_hover_texture
		btn.texture_pressed = answer_pressed_texture
		btn.ignore_texture_size = true
		btn.stretch_mode = TextureButton.STRETCH_SCALE

	for label in q_labels:
		label.mouse_filter = Control.MOUSE_FILTER_IGNORE

	for label in powerup_labels:
		label.mouse_filter = Control.MOUSE_FILTER_IGNORE

func show_random_question() -> void:
	if is_showing:
		return

	_load_questions()

	if questions.is_empty():
		return

	is_showing = true
	get_tree().paused = true
	visible = true
	question_panel.visible = true
	powerup_panel.visible = false

	var q: Dictionary = questions[randi() % questions.size()]
	question_label.text = str(q["text"])
	correct_index = int(q["correct_index"])

	_disconnect_question_buttons()
	_reset_question_buttons()

	var answers: Array = q["answers"]

	for i in range(q_buttons.size()):
		q_labels[i].text = str(answers[i])
		q_buttons[i].disabled = false

		var captured_i := i
		q_buttons[i].pressed.connect(func(): _on_answer(captured_i), CONNECT_ONE_SHOT)

func _on_answer(index: int) -> void:
	_disconnect_question_buttons()

	for btn in q_buttons:
		btn.disabled = true

	var correct := index == correct_index

	if correct:
		_set_button_texture(q_buttons[index], answer_correct_texture)
	else:
		_set_button_texture(q_buttons[index], answer_wrong_texture)
		_set_button_texture(q_buttons[correct_index], answer_correct_texture)

	await get_tree().create_timer(1.0, true, false, true).timeout

	if correct:
		show_powerup_choice()
	else:
		_close()
		answer_selected.emit(false)

func show_powerup_choice() -> void:
	question_panel.visible = false
	powerup_panel.visible = true

	_disconnect_powerup_buttons()
	_reset_powerup_buttons()

	var shuffled: Array = POWERUPS.duplicate()
	shuffled.shuffle()
	available_powerups = shuffled.slice(0, 3)

	for i in range(powerup_buttons.size()):
		powerup_labels[i].text = tr(available_powerups[i]["label_key"])
		powerup_buttons[i].disabled = false

		var captured_i := i
		powerup_buttons[i].pressed.connect(
			func(): _on_powerup_selected(captured_i),
			CONNECT_ONE_SHOT
		)

func _on_powerup_selected(index: int) -> void:
	_close()
	_disconnect_powerup_buttons()

	var player: Node = get_tree().get_first_node_in_group("player")
	if player == null:
		answer_selected.emit(true)
		return

	if player.has_method("apply_powerup"):
		player.apply_powerup(available_powerups[index]["id"])
	
	answer_selected.emit(true)

func _set_button_texture(btn: TextureButton, tex: Texture2D) -> void:
	btn.texture_normal = tex
	btn.texture_hover = tex
	btn.texture_pressed = tex

func _reset_question_buttons() -> void:
	for btn in q_buttons:
		btn.texture_normal = answer_idle_texture
		btn.texture_hover = answer_hover_texture
		btn.texture_pressed = answer_pressed_texture
		btn.disabled = false

func _reset_powerup_buttons() -> void:
	for btn in powerup_buttons:
		btn.texture_normal = answer_idle_texture
		btn.texture_hover = answer_hover_texture
		btn.texture_pressed = answer_pressed_texture
		btn.disabled = false

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

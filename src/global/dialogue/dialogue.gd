extends Control

signal dialogue_finish

@export_file("*.json") var d_file_it
@export_file("*.json") var d_file_en

var dialogue = []
var current_dialogue_id = 0
var dialogue_active = false
var can_advance = true
var just_finished = false


func _ready() -> void:
	visible = false
	$NinePatchRect.visible = false


func start() -> void:
	if dialogue_active or just_finished:
		return

	dialogue = load_dialogue()
	if dialogue.is_empty():
		return

	dialogue_active = true
	can_advance = true
	visible = true
	$NinePatchRect.visible = true
	current_dialogue_id = -1
	next_script()


func load_dialogue() -> Array:
	var file
	if TranslationServer.get_locale().begins_with("en"):
		file = FileAccess.open(d_file_en, FileAccess.READ)
	else:
		file = FileAccess.open(d_file_it, FileAccess.READ)
	if file == null:
		print("Impossibile aprire il file dialogo")
		return []

	var content = JSON.parse_string(file.get_as_text())
	if content == null:
		print("JSON non valido")
		return []

	return content


func _input(event: InputEvent) -> void:
	if event.is_action_released("interact"):
		can_advance = true
		just_finished = false

	if !dialogue_active:
		return

	if event.is_action_pressed("interact") and can_advance:
		can_advance = false
		next_script()


func next_script() -> void:
	current_dialogue_id += 1

	if current_dialogue_id >= dialogue.size():
		dialogue_active = false
		$NinePatchRect.visible = false
		visible = false
		current_dialogue_id = 0
		dialogue = []
		just_finished = true
		emit_signal("dialogue_finish")
		return

	$NinePatchRect/Name.text = dialogue[current_dialogue_id]["name"]
	$NinePatchRect/Text.text = dialogue[current_dialogue_id]["text"]


func force_close() -> void:
	dialogue_active = false
	$NinePatchRect.visible = false
	visible = false
	current_dialogue_id = 0
	dialogue = []
	can_advance = true
	just_finished = false

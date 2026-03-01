extends Control

signal dialogue_finish

@export_file("*.json") var d_file
var dialogue = []
var current_dialogue_id = 0
var dialogue_active = false


func _ready():
	$NinePatchRect.visible = false



func start():
	if dialogue_active:
		return
	dialogue_active = true
	$NinePatchRect.visible = true
	dialogue = load_dialogue()
	current_dialogue_id = -1
	next_script()



func load_dialogue():
	if d_file == "":
		print("Nessun file dialogo assegnato")
		return []
	var file = FileAccess.open(d_file, FileAccess.READ)
	var content = JSON.parse_string(
		file.get_as_text()
	)
	return content



func _input(event):
	if !dialogue_active:
		return
	if event.is_action_pressed("ui_accept"):
		next_script()



func next_script():
	current_dialogue_id += 1
	if current_dialogue_id >= len(dialogue):
		dialogue_active = false
		$NinePatchRect.visible = false
		current_dialogue_id = 0
		dialogue = []
		emit_signal("dialogue_finish")
		return

	$NinePatchRect/Name.text = dialogue[current_dialogue_id]["name"]
	$NinePatchRect/Text.text = dialogue[current_dialogue_id]["text"]

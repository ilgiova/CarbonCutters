extends Sprite2D

# Definiamo i percorsi dei file tramite l'inspector
@export_file("*.json") var intro_file_en: String = "res://src/minigames/eco_survivors/intro_text/intro_en.json"
@export_file("*.json") var intro_file_it: String = "res://src/minigames/eco_survivors/intro_text/intro_it.json"

# Prendiamo la reference al nodo TextEdit (figlio dello Sprite2D)
@onready var text_edit: Label = $TextEdit

func _ready() -> void:
	# Disabilitiamo la scrittura se il TextEdit serve solo in lettura
	_load_intro_text()

# Funzione che carica, fa il parsing e assegna il testo
func _load_intro_text() -> void:
	var current_locale := TranslationServer.get_locale()
	var selected_file: String = intro_file_en # Fallback in inglese

	# Selezioniamo il file corretto in base al prefisso della lingua
	if current_locale.begins_with("it"):
		selected_file = intro_file_it

	# Uscita anticipata (guard clause) se il file non esiste
	if not FileAccess.file_exists(selected_file):
		push_error("File di intro non trovato: " + selected_file)
		return

	# Apertura file e lettura testo
	var file := FileAccess.open(selected_file, FileAccess.READ)
	var content := file.get_as_text()
	
	# Chiusura file automatica, ma procediamo col parsing del JSON
	var parsed = JSON.parse_string(content)

	# Se il JSON è valido, è un Dictionary e contiene la nostra chiave, aggiorniamo l'UI
	if parsed is Dictionary and parsed.has("intro_text"):
		text_edit.text = str(parsed["intro_text"])
	else:
		push_error("Errore nel formato del file JSON dell'intro.")

# Viene chiamata automaticamente dal motore ad ogni evento di input hardware
func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and event.keycode == KEY_E:
		get_tree().paused = false
	
		get_tree().change_scene_to_file("res://src/minigames/eco_survivors/ecosurvivors.tscn")

extends Node2D
class_name OutroScreen

# Definiamo i percorsi dei file tramite l'inspector
@export_file("*.json") var outro_file_en: String = "res://src/minigames/eco_survivors/outro_text/outro_en.json"
@export_file("*.json") var outro_file_it: String = "res://src/minigames/eco_survivors/outro_text/outro_it.json"

# Prendiamo la reference al nodo TextEdit (figlio dello Sprite2D)
@onready var text_edit: TextEdit = $EcoSurvivorsOutro/TextEdit
@onready var points: Label = $Label
var points_get_from_other_scene_i_hate_my_life = 0

func _ready() -> void:
	print(get_children())
	# Disabilitiamo la scrittura se il TextEdit serve solo in lettura
	points.text = str(points_get_from_other_scene_i_hate_my_life)
	text_edit.editable = false 
	_load_outro_text()

# Funzione che carica, fa il parsing e assegna il testo
func _load_outro_text() -> void:
	var current_locale := TranslationServer.get_locale()
	var selected_file: String = outro_file_en # Fallback in inglese

	# Selezioniamo il file corretto in base al prefisso della lingua
	if current_locale.begins_with("it"):
		selected_file = outro_file_it

	# Uscita anticipata (guard clause) se il file non esiste
	if not FileAccess.file_exists(selected_file):
		push_error("File di outro non trovato: " + selected_file)
		return

	# Apertura file e lettura testo
	var file := FileAccess.open(selected_file, FileAccess.READ)
	var content := file.get_as_text()
	
	# Chiusura file automatica, ma procediamo col parsing del JSON
	var parsed = JSON.parse_string(content)

	# Se il JSON è valido, è un Dictionary e contiene la nostra chiave, aggiorniamo l'UI
	if parsed is Dictionary and parsed.has("outro_text"):
		text_edit.text = str(parsed["outro_text"])
	else:
		push_error("Errore nel formato del file JSON dell'outro.")

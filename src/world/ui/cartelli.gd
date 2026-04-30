extends Node2D

# Percorsi ai file JSON per le traduzioni dei cartelli
@export_file("*.json") var signsFileEn: String
@export_file("*.json") var signsFileIt: String

# L'ID univoco di questo cartello per cercarlo nel JSON (es. "statua_liberta")
@export var sign_id: String = "default_id"

@export var popup_ui: CanvasLayer

@onready var icon: AnimatedSprite2D = $IconKeyboard
@onready var label_testo: Label = $popui/Label

var body_inside := false
var is_reading := false

func _ready() -> void:
	# Set iniziale dell'interfaccia
	icon.visible = false
	if popup_ui != null:
		popup_ui.visible = false
		
	# Carica la traduzione corretta all'avvio
	load_localized_text()

# Apre il JSON corretto e applica il testo alla Label
func load_localized_text() -> void:
	# Seleziona il percorso base assumendo l'italiano come default
	var file_path: String = signsFileIt
	
	# Se la lingua di sistema è inglese, sovrascrive il percorso
	if TranslationServer.get_locale().begins_with("en"):
		file_path = signsFileEn
		
	# Se il file non è stato assegnato nell'Inspector, blocca l'esecuzione
	if file_path == null or file_path == "":
		return
		
	# Apre il file in modalità lettura
	var file = FileAccess.open(file_path, FileAccess.READ)
	if file != null:
		var content = file.get_as_text()
		var parsed = JSON.parse_string(content)
		
		# Verifica che il JSON sia un Dictionary e che contenga la nostra chiave
		if typeof(parsed) == TYPE_DICTIONARY and parsed.has(sign_id):
			if label_testo != null:
				label_testo.text = str(parsed[sign_id])
		else:
			print("Errore: ID non trovato nel file JSON -> ", sign_id)
			
# Logica di interazione mantenuta identica
func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("interact") and body_inside:
		is_reading = not is_reading
		if popup_ui != null:
			popup_ui.visible = is_reading
		icon.visible = not is_reading

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("player") or body.name.to_lower().find("player") != -1:
		body_inside = true
		if not is_reading:
			icon.visible = true
			icon.play("default")

func _on_area_2d_body_exited(body: Node2D) -> void:
	if body.is_in_group("player") or body.name.to_lower().find("player") != -1:
		body_inside = false
		is_reading = false
		icon.stop()
		icon.visible = false
		if popup_ui != null:
			popup_ui.visible = false

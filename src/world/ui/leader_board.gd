#leader board

extends CanvasLayer

@onready var label = 		[$Control/MarginContainer/HBoxContainer/VBoxContainer/Player1/Label, 
							$Control/MarginContainer/HBoxContainer/VBoxContainer/Player2/Label,
							$Control/MarginContainer/HBoxContainer/VBoxContainer/Player3/Label,
							$Control/MarginContainer/HBoxContainer/VBoxContainer/Player4/Label,
							$Control/MarginContainer/HBoxContainer/VBoxContainer/Player5/Label,
							$Control/MarginContainer/HBoxContainer/VBoxContainer2/Player1/Label,
							$Control/MarginContainer/HBoxContainer/VBoxContainer2/Player2/Label,
							$Control/MarginContainer/HBoxContainer/VBoxContainer2/Player3/Label,
							$Control/MarginContainer/HBoxContainer/VBoxContainer2/Player4/Label,
							$Control/MarginContainer/HBoxContainer/VBoxContainer2/Player5/Label]


func _ready() -> void:
	PlayerData.save_data()
	var viewport_size = get_viewport().get_visible_rect().size
	$Control/MarginContainer.position = viewport_size / 2 - $Control/MarginContainer.size / 2
	PlayerData.leaderboard_loaded.connect(_on_leaderboard_loaded)
	PlayerData.leaderboard_failed.connect(_on_leaderboard_failed)
	PlayerData.fetch_leaderboard()
	process_mode = Node.PROCESS_MODE_ALWAYS
	

func _on_leaderboard_loaded(data: Array) -> void:
	# Aggiunge ogni giocatore
	for i in data.size():
		var entry = data[i]
		if entry["name"] == PlayerData.getUserName():
			label[i].add_theme_color_override("font_color", Color(0.081, 0.34, 0.079, 1.0))
		label[i].text = "%s: %d" % [entry["name"], entry["score"]]

func _on_leaderboard_failed() -> void:
	print("Errore nel caricamento...")

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("ui_accept") or Input.is_action_just_pressed("ui_cancel"):
		get_tree().paused = false
		queue_free()

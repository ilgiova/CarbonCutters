extends TextureButton

func _ready() -> void:
	# 1. Diciamo al bottone di funzionare sempre, anche se il gioco è in pausa al Game Over
	process_mode = Node.PROCESS_MODE_ALWAYS
	
	# 2. Colleghiamo via codice il segnale nativo 'pressed' a questo stesso script
	pressed.connect(_on_texture_button_pressed)

func _on_texture_button_pressed() -> void:
	# 3. FONDAMENTALE: rimuoviamo la pausa prima di cambiare scena,
	# altrimenti il livello si caricherà ma sarà completamente bloccato!
	get_tree().paused = false
	
	# 4. Cambiamo la scena
	get_tree().change_scene_to_file("res://src/minigames/eco_survivors/ecosurvivors.tscn")

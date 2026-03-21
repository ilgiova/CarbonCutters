extends CanvasLayer

@onready var panel: Panel = $Panel
@onready var title_label: Label = $Panel/CenterContainer/VBoxContainer/TitleLabel
@onready var resume_button: TextureButton = $Panel/CenterContainer/VBoxContainer/ResumeButton
@onready var lobby_button: TextureButton = $Panel/CenterContainer/VBoxContainer/LobbyButton
@onready var exit_button: TextureButton = $Panel/CenterContainer/VBoxContainer/ExitButton

var is_open: bool = false


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	hide()
	

	if resume_button == null:
		print("ERRORE: ResumeButton non trovato")
	if lobby_button == null:
		print("ERRORE: LobbyButton non trovato")
	if exit_button == null:
		print("ERRORE: ExitButton non trovato")


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("MainMenu"):
		if is_open:
			close_menu()
		else:
			open_menu()


func open_menu() -> void:
	is_open = true
	get_tree().paused = true
	update_buttons()
	show()


func close_menu() -> void:
	is_open = false
	get_tree().paused = false
	hide()


func update_buttons() -> void:
	if lobby_button == null:
		return

	if PlayerData.current_context == "lobby":
		lobby_button.hide()
	else:
		lobby_button.show()


func _on_resume_button_pressed() -> void:
	close_menu()


func _on_lobby_button_pressed() -> void:
	is_open = false
	get_tree().paused = false
	hide()
	get_tree().change_scene_to_file("res://src/world/game_scene.tscn")


func _on_exit_button_pressed() -> void:
	get_tree().quit()

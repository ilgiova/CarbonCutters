extends Control

@onready var username_input: LineEdit = $VBoxContainer/UsernameInput
@onready var password_input: LineEdit = $VBoxContainer/PasswordInput
@onready var login_btn: TextureButton = $VBoxContainer/LoginBtn
@onready var login_label: Label = $VBoxContainer/LoginBtn/Label
@onready var signup_btn: TextureButton = $VBoxContainer/SignupBtn
@onready var signup_label: Label = $VBoxContainer/SignupBtn/Label
@onready var status_label: Label = $VBoxContainer/StatusLabel

const RETURN_SCENE_PATH = "res://src/world/ui/main_menu.tscn"
var logged_in: bool = false

func _ready() -> void:
	login_btn.pressed.connect(_on_login_pressed)
	signup_btn.pressed.connect(_on_signup_pressed)
	
	PlayerData.login_success.connect(_on_login_success)
	PlayerData.login_failed.connect(_on_login_failed)
	PlayerData.signup_success.connect(_on_signup_success)
	PlayerData.signup_failed.connect(_on_signup_failed)
	
	status_label.text = ""
	
	if PlayerData.isLoggedIn():
		_show_logged_state()
	else:
		_show_login_state()


# UI: stato "loggato" — mostra logout
func _show_logged_state() -> void:
	password_input.visible = false
	username_input.text = PlayerData.getUserName()
	username_input.editable = false
	username_input.mouse_filter = Control.MOUSE_FILTER_IGNORE
	
	signup_btn.visible = false
	signup_label.visible = false
	login_label.text = tr("LOG_OUT")
	logged_in = true

# UI: stato "non loggato" — mostra form di login
func _show_login_state() -> void:
	password_input.visible = true
	password_input.text = ""
	username_input.text = ""
	username_input.editable = true
	username_input.mouse_filter = Control.MOUSE_FILTER_STOP
	
	signup_btn.visible = true
	signup_label.visible = true
	login_label.text = tr("LOGIN")
	logged_in = false
	
	status_label.text = ""


func _on_login_pressed() -> void:
	Audio.play_sfx(preload("res://sound/ButtonHoverEffect.mp3"))
	if not logged_in:
		status_label.text = tr("ACCESS")+".."
		status_label.modulate = Color.WHITE
		PlayerData.login(username_input.text, password_input.text)
	else:
		# Logout
		PlayerData.logout()
		status_label.text = tr("DISCONNECTED")
		status_label.modulate = Color.YELLOW
		_show_login_state()

func _on_signup_pressed() -> void:
	Audio.play_sfx(preload("res://sound/ButtonHoverEffect.mp3"))
	status_label.text =tr("REGISTRATION") + "..."
	status_label.modulate = Color.WHITE
	PlayerData.signup(username_input.text, password_input.text)

func _on_login_success() -> void:
	status_label.text = tr("WELCOME")+", " + PlayerData.current_user + "!"
	status_label.modulate = Color.GREEN
	await get_tree().create_timer(1.0).timeout
	get_tree().change_scene_to_file(RETURN_SCENE_PATH)

func _on_login_failed(reason: String) -> void:
	status_label.text = reason
	status_label.modulate = Color.RED

func _on_signup_success() -> void:
	status_label.text = tr("CREATED") +", " + PlayerData.current_user + "!"
	status_label.modulate = Color.GREEN
	await get_tree().create_timer(1.5).timeout
	get_tree().change_scene_to_file(RETURN_SCENE_PATH)

func _on_signup_failed(reason: String) -> void:
	status_label.text = reason
	status_label.modulate = Color.RED
	
	
	


func _on_go_back_pressed() -> void:
	Audio.play_sfx(preload("res://sound/ButtonHoverEffect.mp3"))
	get_tree().change_scene_to_file("res://src/world/ui/main_menu.tscn")

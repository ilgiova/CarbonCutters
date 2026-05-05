extends Control

enum PlayState { PLAYING, STOPPED, AUTO }


@onready var round_label: Label = $Layout/RoundLabel
@onready var hp_label: Label = $Layout/HpLabel
@onready var skip_btn: TextureButton = $Layout/CenterContainer/HBoxContainer/SkipBtn
@onready var speed_btn: TextureButton = $Layout/CenterContainer/HBoxContainer/SpeedBtn
@onready var speed_btn_label: Label = $Layout/CenterContainer/HBoxContainer/SpeedBtn/Label


# Texture per i 3 stati del bottone play
@export var texture_playing: Texture2D
@export var texture_stopped: Texture2D
@export var texture_auto: Texture2D

var _wave_manager: Node = null
var _state: PlayState = PlayState.STOPPED

# Velocità di gioco
var _speeds: Array[float] = [1.0, 2.0, 3.0]
var _speed_index: int = 0

func setup(wave_manager: Node, game: Node = null) -> void:
	_wave_manager = wave_manager
	_wave_manager.round_started.connect(_on_round_started)
	_wave_manager.round_completed.connect(_on_round_completed)
	skip_btn.pressed.connect(_on_play_pressed)
	speed_btn.pressed.connect(_on_speed_pressed)
	
	if game:
		print("Setup HP label, game: ", game, " player_hp: ", game.player_hp)
		game.player_hp_changed.connect(_on_player_hp_changed)
		if hp_label:
			hp_label.text = "HP: %d" % game.player_hp
		else:
			print("ERRORE: hp_label è null!")
	else:
		print("ERRORE: game è null nella setup!")
	
	round_label.text = "Round: 0"
	speed_btn_label.text = "1x"
	_set_state(PlayState.STOPPED)


# --- Round state ---

func _on_round_started(round_number: int) -> void:
	round_label.text = "Round: %d" % round_number
	if _state != PlayState.AUTO:
		_set_state(PlayState.PLAYING)

func _on_round_completed(_round_number: int) -> void:
	if _state != PlayState.AUTO:
		_set_state(PlayState.STOPPED)

func _on_play_pressed() -> void:
	match _state:
		PlayState.STOPPED:
			_set_state(PlayState.PLAYING)
			_wave_manager.auto_continue = false
			_wave_manager.request_next_round()
		PlayState.PLAYING:
			_set_state(PlayState.AUTO)
			_wave_manager.auto_continue = true
		PlayState.AUTO:
			_set_state(PlayState.PLAYING)
			_wave_manager.auto_continue = false

func _set_state(new_state: PlayState) -> void:
	_state = new_state
	match _state:
		PlayState.PLAYING:
			skip_btn.texture_normal = texture_playing
		PlayState.STOPPED:
			skip_btn.texture_normal = texture_stopped
		PlayState.AUTO:
			skip_btn.texture_normal = texture_auto

# --- Speed control ---

func _on_speed_pressed() -> void:
	_speed_index = (_speed_index + 1) % _speeds.size()
	Engine.time_scale = _speeds[_speed_index]
	speed_btn_label.text = "%.0fx" % _speeds[_speed_index]

func _exit_tree() -> void:
	# Reset velocità quando si esce dal mini-gioco
	Engine.time_scale = 1.0

func _on_player_hp_changed(new_hp: int) -> void:
	hp_label.text = "HP: %d" % new_hp

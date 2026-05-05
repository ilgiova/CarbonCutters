extends Control

@onready var score_label: Label = $ContentMargin/Layout/ScoreBox/ScoreMargin/ScoreLabel
@onready var round_label: Label = $ContentMargin/Layout/StatsContainer/RoundLabel
@onready var enemies_label: Label = $ContentMargin/Layout/StatsContainer/EnemiesKilledLabel
@onready var gold_label: Label = $ContentMargin/Layout/StatsContainer/GoldEarnedLabel
@onready var play_again_btn: TextureButton = $ContentMargin/Layout/ButtonsRow/PlayAgainBtn
@onready var main_menu_btn: TextureButton = $ContentMargin/Layout/ButtonsRow/MainMenuBtn

signal play_again_pressed
signal main_menu_pressed

func _ready() -> void:
	PlayerData.save_data()
	play_again_btn.pressed.connect(func(): play_again_pressed.emit())
	main_menu_btn.pressed.connect(func(): main_menu_pressed.emit())

# Chiama questa dalla scena del gioco quando il giocatore perde
func show_results(rounds_reached: int, enemies_killed: int, gold_earned: int) -> void:
	# Score = somma da 1 a N di (i × 2) = N × (N + 1)
	var total_score = rounds_reached * (rounds_reached + 1)
	
	# Animazione: counter che sale da 0 al valore finale
	_animate_counter(score_label, "Score: %d", 0, total_score, 1.5)
	_animate_counter(round_label, tr("ECO_VALLEY_END_ROUND_REACHED") + ": %d", 0, rounds_reached, 1.0)
	_animate_counter(enemies_label, tr("ECO_VALLEY_END_ENEMIES_KILLED") + ": %d", 0, enemies_killed, 1.2)
	_animate_counter(gold_label, tr("ECO_VALLEY_END_GOLD_EARNED") + ": %d", 0, gold_earned, 1.0)


func _animate_counter(label: Label, format: String, from: int, to: int, duration: float) -> void:
	var tween = create_tween()
	tween.tween_method(
		func(value: int): label.text = format % value,
		from, to, duration
	).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)

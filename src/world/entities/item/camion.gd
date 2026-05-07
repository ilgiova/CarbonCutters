extends Node2D

var is_moving: bool = true
var body_inside: bool = false

@onready var dust: CPUParticles2D = $dust2
@onready var dust1: CPUParticles2D = $dust
@onready var spriteKey: AnimatedSprite2D = $IconKeyboard
@onready var popup: CanvasLayer = $popui

func _ready() -> void:
	popup.visible = false
	spriteKey.visible = false

func _process(_delta):
	# Controlla l'input ogni frame, ma solo se il player è dentro
	if body_inside and Input.is_action_just_pressed("interact"):
		vendiOggetti()
		popup.visible = true

func ferma():
	var parent = get_parent()
	if parent is PathFollow2D:
		parent.is_moving = false

func riparti():
	var parent = get_parent()
	if parent is PathFollow2D:
		parent.is_moving = true

func _on_area_2d_2_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		body_inside = true
		ferma()
		dust.emitting = false
		dust1.emitting = false
		spriteKey.visible = true
		spriteKey.play("default")

func _on_area_2d_2_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		body_inside = false
		riparti()
		dust.emitting = true
		dust1.emitting = true
		spriteKey.visible = false
		spriteKey.stop()
		popup.visible = false

func vendiOggetti() -> void:
	var totale_oggetti: int = (
		PlayerData.getPlasticCount() + 
		PlayerData.getCardboardCount() + 
		PlayerData.getGlassCount() + 
		PlayerData.getAluminumCount() + 
		PlayerData.getOrganicCount()
	)
	
	if totale_oggetti == 0:
		return
		
	var punti_guadagnati: int = totale_oggetti * 10
	PlayerData.add_score(punti_guadagnati)
	
	PlayerData.plasticCount = 0
	PlayerData.cardboardCount = 0
	PlayerData.glassCount = 0
	PlayerData.aluminumCount = 0
	PlayerData.organicCount = 0

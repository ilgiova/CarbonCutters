extends Control

@onready var italianButton: TextureButton = $Panel/BoxContainer/HBoxContainer/MarginContainer/Italian
@onready var englishButton: TextureButton = $Panel/BoxContainer/HBoxContainer/MarginContainer2/English

#label for traduction
@onready var settingLabel: Label = $Panel/BoxContainer/MarginContainer4/TitleLabel
@onready var goBackLabel: Label = $Panel/BoxContainer/MarginContainer3/Label

@export var normalTexture: Texture2D
@export var hoverTexture: Texture2D
@export var pressedTexture: Texture2D

func _ready() -> void:
	for button in [italianButton, englishButton]:
		button.toggle_mode = true
		button.texture_normal = normalTexture
		button.texture_hover = hoverTexture
		button.texture_pressed = pressedTexture

	if TranslationServer.get_locale() == "en":
		englishButton.set_pressed_no_signal(true)
		italianButton.set_pressed_no_signal(false)
	else:
		englishButton.set_pressed_no_signal(false)
		italianButton.set_pressed_no_signal(true)


func _on_italian_pressed() -> void:
	Audio.play_sfx(preload("res://sound/ButtonHoverEffect.mp3"))
	italianButton.button_pressed = true
	englishButton.button_pressed = false
	TranslationServer.set_locale("it")

func _on_english_pressed() -> void:
	Audio.play_sfx(preload("res://sound/ButtonHoverEffect.mp3"))
	englishButton.button_pressed = true
	italianButton.button_pressed = false
	TranslationServer.set_locale("en")

func _on_go_back_pressed() -> void:
	Audio.play_sfx(preload("res://sound/ButtonHoverEffect.mp3"))
	get_tree().change_scene_to_file("res://src/world/ui/main_menu.tscn")


func _on_h_slider_value_changed(value: float) -> void:
	Audio.set_master_volume(value)

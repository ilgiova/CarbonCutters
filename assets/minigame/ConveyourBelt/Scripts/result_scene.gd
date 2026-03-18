extends Control

@onready var foodLabel: Label = $VBoxContainer/FoodText
@onready var paperLabel: Label = $VBoxContainer/CardboardText
@onready var plasticLabel: Label = $VBoxContainer/PlasticText
@onready var wasteLabel: Label = $VBoxContainer/WasteText
@onready var pointsLabel: Label = $VBoxContainer/PointText
@onready var buttonPlay: TextureButton = $VBoxContainer/HBoxContainer/PlayAgain
@onready var buttonLobby: TextureButton = $VBoxContainer/HBoxContainer/Lobby

var foodPoint = 0
var cardboardPoint = 0
var plasticPoint = 0 
var missedPoint = 0
var totalPoint  = 0




func _ready() -> void:
	foodLabel.text = "Food recycled: " + str(foodPoint)
	paperLabel.text = "Cardbard recycled: " + str(cardboardPoint)
	plasticLabel.text = "Plastic recycled: " + str(plasticPoint)
	wasteLabel.text = "Missed item: " + str(missedPoint)
	pointsLabel.text = "Total points: " + str(totalPoint)


func _on_play_again_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/minigame/conveyorBeltGame.tscn")
	queue_free()
	
func _on_lobby_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/game_scene.tscn")
	queue_free()

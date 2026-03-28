extends Control

@onready var foodLabel: Label = $VBoxContainer/FoodText
@onready var paperLabel: Label = $VBoxContainer/CardboardText
@onready var plasticLabel: Label = $VBoxContainer/PlasticText
@onready var wasteLabel: Label = $VBoxContainer/WasteText
@onready var pointsLabel: Label = $VBoxContainer/PointText

var foodPoint = 0
var cardboardPoint = 0
var plasticPoint = 0 
var missedPoint = 0
var totalPoint  = 0




func _ready() -> void:
	foodLabel.text = tr("FOOD_RECYCLED") + ": " + str(foodPoint)
	paperLabel.text = tr("CARDBOARD_RECYCLED") + ": " + str(cardboardPoint)
	plasticLabel.text = tr("PLASTIC_RECYCLED") + ": " + str(plasticPoint)
	wasteLabel.text = tr("MISSED_POINT") + ": " + str(missedPoint)
	pointsLabel.text = tr("TOTAL_POINT") + ": " + str(totalPoint)


func _on_play_again_pressed() -> void:
	get_tree().change_scene_to_file("res://src/minigames/conveyor_belt/conveyor_belt_game.tscn")
	queue_free()
	

func _on_go_lobby_pressed() -> void:
	get_tree().change_scene_to_file("res://src/world/game_scene.tscn")
	queue_free()

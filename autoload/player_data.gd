extends Node

var score := 0
var cardboardCount: int = 0
var glassCount: int = 0
var aluminumCount: int = 0
var plasticCount: int = 0
var organicCount: int = 0
var current_context: String = "lobby"

func _ready() -> void:
	TranslationServer.set_locale("en")

func add_score(points: int):
	score += points
	
func get_score():
	return score

func addItem(itemType: int) -> void:
	match itemType:
		0:
			plasticCount += 1
		1:
			cardboardCount += 1
		2:
			glassCount += 1
		3:
			aluminumCount += 1
		4:
			organicCount += 1


func resetData() -> void:
	plasticCount = 0
	cardboardCount = 0
	glassCount = 0
	aluminumCount = 0
	
func getCardboardCount():
	return cardboardCount
func getGlassCount():
	return glassCount
func getAluminumCount():
	return aluminumCount
func getPlasticCount():
	return plasticCount
func getOrganicCount():
	return organicCount

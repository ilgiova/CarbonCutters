extends Node

var score := 0
var current_context: String = "lobby"

func add_score(points: int):
	score += points
	
func get_score():
	return score

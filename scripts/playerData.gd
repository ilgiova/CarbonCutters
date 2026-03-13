extends Node2D

var score := 0

func add_score(points: int):
	score += points
	
func get_score():
	return score

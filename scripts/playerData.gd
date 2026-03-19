extends Node2D

var score := 0
var current_context: String = "lobby"
var main_lobby_path: String = "res://scenes/main_lobby.tscn"

func add_score(points: int):
	score += points
	
func get_score():
	return score

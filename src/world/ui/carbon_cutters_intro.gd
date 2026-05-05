extends Control

func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and event.keycode == KEY_ENTER:
		get_tree().change_scene_to_file("res://src/world/game_scene.tscn")

extends Control


func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("interact"):
		print("WHy")
		get_tree().change_scene_to_file("res://src/minigames/eco_valley_defense/eco_valley_defense.tscn")
			

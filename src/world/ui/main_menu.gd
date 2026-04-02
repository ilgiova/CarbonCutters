extends Control



func _on_startbutton_pressed() -> void:
	Audio.play_sfx(preload("res://sound/ButtonHoverEffect.mp3"))
	get_tree().change_scene_to_file("res://src/world/game_scene.tscn")
	queue_free()



func _on_exit_button_pressed() -> void:
	Audio.play_sfx(preload("res://sound/ButtonHoverEffect.mp3"))
	get_tree().quit()


func _on_setting_pressed() -> void:
	Audio.play_sfx(preload("res://sound/ButtonHoverEffect.mp3"))
	get_tree().change_scene_to_file("res://src/world/ui/setting.tscn")
	queue_free()

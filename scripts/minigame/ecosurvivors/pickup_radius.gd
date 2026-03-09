extends Area2D

func _physics_process(_delta) -> void:
	var areas = get_overlapping_areas()
	for area in areas:
		if area.has_method("attract"):
			area.attract(get_parent())

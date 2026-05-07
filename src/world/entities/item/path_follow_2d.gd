extends PathFollow2D

@export var speed: float = 100.0
@export var loop_path: bool = true
var is_moving: bool = true

func _process(delta):
	if is_moving:
		progress += speed * delta
	
	# Se non vuoi che ricominci dall'inizio
	if not loop_path and progress_ratio >= 1.0:
		set_process(false)

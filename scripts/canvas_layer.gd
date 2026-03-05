extends CanvasLayer

@onready var label = $Label

func _process(delta):
	label.text = "Score: " + str(PlayerData.score)

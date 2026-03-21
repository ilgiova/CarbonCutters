extends CanvasLayer

@onready var label = $Label

func _process(_delta):
	label.text = "Score: " + str(PlayerData.score)

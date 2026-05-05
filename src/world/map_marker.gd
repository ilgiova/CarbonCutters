extends Control
 
@export var world_position: Vector2i = Vector2i(0, 0) # posizione nel mondo (pixel)
@export var label_text: String = ""

@onready var label = $MarginContainer/TextureRect/Label

func _ready():
	label.text = label_text
	await get_tree().process_frame 
	
	pivot_offset = Vector2(size.x / 2, size.y)

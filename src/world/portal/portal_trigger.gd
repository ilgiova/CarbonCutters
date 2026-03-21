extends Node2D

@export_file("*.tscn") var target_scene: String
@export var sprite_texture: Texture2D
@onready var sprite: Sprite2D = $Sprite2D
@onready var icon: AnimatedSprite2D = $IconKeyboard

var body_inside := false


func _ready() -> void:
	sprite.texture = sprite_texture

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("interact") and body_inside:
		if target_scene != "":
			get_tree().change_scene_to_file(target_scene)
			queue_free()


func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("player") or body.name.to_lower().find("player") != -1:
		body_inside = true
		icon.visible = true
		icon.play("default")


func _on_area_2d_body_exited(body: Node2D) -> void:
	if body.is_in_group("player") or body.name.to_lower().find("player") != -1:
		body_inside = false
		icon.stop()
		icon.visible = false

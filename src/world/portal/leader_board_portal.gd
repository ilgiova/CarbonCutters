#leader board portal
extends Node2D


@onready var sprite: Sprite2D = $Sprite2D
@onready var icon: AnimatedSprite2D = $IconKeyboard

var body_inside := false


func _ready() -> void:
	icon.visible = false
	

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("interact") and body_inside:
		get_tree().paused = true
		var scene = preload("res://src/world/ui/leader_board.tscn").instantiate()
		get_tree().root.add_child(scene)


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

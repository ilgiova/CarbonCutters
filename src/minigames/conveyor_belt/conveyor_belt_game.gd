extends Node2D

@onready var anim: AnimatedSprite2D = $conveyourBelt/BeltSprite
@onready var timer: Timer = $Timer
@onready var spawnPoint: Marker2D = $conveyourBelt/spawnPoint
@onready var itemsContainer: Node2D = $Items

@onready var pistonA: Node2D = $Pistons/PistonA
@onready var pistonB: Node2D = $Pistons/PistonB
@onready var pistonC: Node2D = $Pistons/PistonC

@onready var timerLabel: Label = $UI/TimerLabel
@onready var scoreLabel: Label = $UI/MarginContainer/Label
@onready var countdownBg: ColorRect = $UI/CountdownBg
@onready var countdownShadow: Label = $UI/CountdownShadow
@onready var countdownLabel: Label = $UI/CountdownLabel

@onready var a: AnimatedSprite2D = $Button/A
@onready var s: AnimatedSprite2D = $Button/S
@onready var d: AnimatedSprite2D = $Button/D

@export var itemScenes: Array[PackedScene]
@export var conveyorSpeed := 400.0

var point = 0
var gameTimeLeft = 60.0
var itemsOnConveyourBelt = []
var foodPoint = 0
var cardboardPoint = 0
var plasticPoint = 0 
var missedPoint = 0

var game_started = false
var speed_increased = false

var lastItemIndex = -1
var sameItemCount = 0

var pistonBodies = {
	"A": null,
	"B": null,
	"C": null
}

var pistonInputs = {
	"A": "left",
	"B": "down",
	"C": "right"
}

var binTypes = {
	"pet": "plastic",
	"food": "organic",
	"cardboard": "paper"
}

var pistonNodes = {}

func _ready() -> void:

	PlayerData.current_context = "minigame"
	randomize()
	
	pistonNodes = {
		"A": pistonA,
		"B": pistonB,
		"C": pistonC
	}

	countdownBg.visible = false
	countdownShadow.visible = false
	countdownLabel.visible = false

	timerLabel.text = "%02d" % int(gameTimeLeft)
	scoreLabel.text = "Score: " + str(point)

	startCountdown()

func startCountdown() -> void:
	game_started = false

	var numbers = ["3", "2", "1", "GO!"]

	for text in numbers:
		countdownBg.visible = true
		countdownShadow.visible = true
		countdownLabel.visible = true

		countdownLabel.text = text
		countdownShadow.text = text

		if text == "GO!":
			countdownLabel.modulate = Color(0.3, 1.0, 0.3, 1.0)
			countdownShadow.modulate = Color(0.0, 0.0, 0.0, 0.35)
		else:
			countdownLabel.modulate = Color(1, 1, 1, 1)
			countdownShadow.modulate = Color(0.0, 0.0, 0.0, 0.35)

		countdownBg.modulate = Color(0, 0, 0, 0.35)

		countdownLabel.scale = Vector2(2.2, 2.2)
		countdownShadow.scale = Vector2(2.8, 2.8)

		var tween = create_tween()
		tween.set_parallel(true)

		tween.tween_property(countdownLabel, "scale", Vector2(1.0, 1.0), 0.45)
		tween.tween_property(countdownShadow, "scale", Vector2(1.4, 1.4), 0.45)

		tween.tween_property(countdownLabel, "modulate:a", 0.0, 0.85)
		tween.tween_property(countdownShadow, "modulate:a", 0.0, 0.85)

		await get_tree().create_timer(1.0).timeout

	countdownBg.visible = false
	countdownShadow.visible = false
	countdownLabel.visible = false
	timerLabel.visible = true
	anim.play("default")
	a.play("default")
	s.play("default")
	d.play("default")

	game_started = true
	startRandomTimer()

func startRandomTimer() -> void:
	if speed_increased:
		timer.wait_time = randf_range(0.5, 1.5)
	else:
		timer.wait_time = randf_range(0.8, 2.0)

	timer.start()

func spawnItem() -> void:
	if itemScenes.is_empty():
		return

	var index = randi() % itemScenes.size()

	if itemScenes.size() > 1:
		if index == lastItemIndex:
			sameItemCount += 1
		else:
			sameItemCount = 1

		if sameItemCount > 2:
			while index == lastItemIndex:
				index = randi() % itemScenes.size()
			sameItemCount = 1
	else:
		sameItemCount = 1

	lastItemIndex = index

	var scene = itemScenes[index]
	var item = scene.instantiate()
	itemsContainer.add_child(item)
	
	item.global_position = spawnPoint.global_position

func _on_timer_timeout() -> void:
	if not game_started:
		return

	spawnItem()
	startRandomTimer()

func _process(delta):
	scoreLabel.text = tr("SCORE")+": " + str(point)
	if not game_started:
		return

	if gameTimeLeft > 0:
		gameTimeLeft -= delta

		if gameTimeLeft <= 30 and not speed_increased:
			speed_increased = true
			conveyorSpeed = 500.0
			startRandomTimer()

		if gameTimeLeft < 4:
			timerLabel.modulate = Color.RED

		timerLabel.text = "%02d" % int(gameTimeLeft)
	else:
		timerLabel.text = "0"
		PlayerData.add_score(point)
		var scene = preload("res://src/minigames/conveyor_belt/scenes/result_scene.tscn").instantiate()
		scene.foodPoint = foodPoint
		scene.cardboardPoint = cardboardPoint
		scene.plasticPoint = plasticPoint 
		scene.missedPoint = missedPoint
		scene.totalPoint = point
		PlayerData.save_data()
		get_tree().root.add_child(scene)
		queue_free()

	

func _physics_process(_delta: float) -> void:
	if not game_started:
		return

	moveItemsOnBelt()
	handlePistonInput()

func moveItemsOnBelt() -> void:
	for item in itemsOnConveyourBelt:
		if is_instance_valid(item) and item is RigidBody2D:
			var vel = item.linear_velocity
			vel.x = conveyorSpeed
			vel.y = 0
			item.linear_velocity = vel

func handlePistonInput() -> void:
	tryActivatePiston("A")
	tryActivatePiston("B")
	tryActivatePiston("C")

func tryActivatePiston(pistonKey: String) -> void:
	var pistonBody = pistonBodies[pistonKey]
	var actionName = pistonInputs[pistonKey]

	if pistonBody == null:
		return
	if not Input.is_action_just_pressed(actionName):
		return

	pistonActivation(pistonBody, pistonKey)
	pistonBodies[pistonKey] = null

func pistonActivation(piston: RigidBody2D, pistonKey: String) -> void:
	if itemsOnConveyourBelt.has(piston):
		itemsOnConveyourBelt.erase(piston)

	piston.gravity_scale = 3

	var pistonNode = pistonNodes[pistonKey]
	pistonNode.playAnimation()

	var vel = piston.linear_velocity
	vel.x = 0
	vel.y = 600
	piston.linear_velocity = vel

func checkBin(body: Node2D, correctType: String) -> void:
	if body is RigidBody2D:
		if body.itemType == correctType:
			match correctType:
				"organic": foodPoint+=1
				"plastic": plasticPoint+=1
				"paper": cardboardPoint+=1
			
			point += 10
		else:
			if point > 0:
				missedPoint += 1
				point -= 5

		if itemsOnConveyourBelt.has(body):
			itemsOnConveyourBelt.erase(body)

		body.queue_free()

func registerBodyOnBelt(body: Node2D) -> void:
	if body is RigidBody2D:
		if not itemsOnConveyourBelt.has(body):
			itemsOnConveyourBelt.append(body)
		body.gravity_scale = 0

func unregisterBodyFromBelt(body: Node2D) -> void:
	if body is RigidBody2D:
		body.gravity_scale = 3
		if itemsOnConveyourBelt.has(body):
			itemsOnConveyourBelt.erase(body)

func _on_conveyor_area_body_entered(body: Node2D) -> void:
	registerBodyOnBelt(body)

func _on_conveyor_area_body_exited(body: Node2D) -> void:
	unregisterBodyFromBelt(body)

func _on_trash_can_body_entered(body: Node2D) -> void:
	if body is RigidBody2D:
		if itemsOnConveyourBelt.has(body):
			itemsOnConveyourBelt.erase(body)
		missedPoint += 1
		body.queue_free()
		
		if point > 0:
			point -= 5
			

func _on_piston_a_body_entered(body: Node2D) -> void:
	if body is RigidBody2D:
		pistonBodies["A"] = body

func _on_piston_a_body_exited(body: Node2D) -> void:
	if body == pistonBodies["A"]:
		pistonBodies["A"] = null

func _on_piston_b_body_entered(body: Node2D) -> void:
	if body is RigidBody2D:
		pistonBodies["B"] = body

func _on_piston_b_body_exited(body: Node2D) -> void:
	if body == pistonBodies["B"]:
		pistonBodies["B"] = null

func _on_piston_c_body_entered(body: Node2D) -> void:
	if body is RigidBody2D:
		pistonBodies["C"] = body

func _on_piston_c_body_exited(body: Node2D) -> void:
	if body == pistonBodies["C"]:
		pistonBodies["C"] = null

func _on_food_trash_body_entered(body: Node2D) -> void:
	checkBin(body, "organic")

func _on_pet_trash_body_entered(body: Node2D) -> void:
	checkBin(body, "plastic")

func _on_cardboard_trash_body_entered(body: Node2D) -> void:
	checkBin(body, "paper")

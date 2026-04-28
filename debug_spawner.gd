extends PanelContainer

@export var available_enemies: Array[EnemyData] = []

@onready var enemy_dropdown: OptionButton = $MarginContainer/VBoxContainer/HBoxContainer/EnemyDropdown
@onready var quantity_spin: SpinBox = $MarginContainer/VBoxContainer/HBoxContainer/QuantitySpin
@onready var spawn_btn: Button = $MarginContainer/VBoxContainer/SpawnBtn
@onready var gold_btn: Button = $MarginContainer/VBoxContainer/GoldBtn
@onready var kill_all_btn: Button = $MarginContainer/VBoxContainer/KillAllBtn

# Riferimento alla scena principale per chiamare le sue funzioni
var game: Node = null

func _ready() -> void:
	# Popola dropdown con i nemici disponibili
	for i in available_enemies.size():
		enemy_dropdown.add_item(available_enemies[i].enemy_name, i)
	
	spawn_btn.pressed.connect(_on_spawn_pressed)
	gold_btn.pressed.connect(_on_gold_pressed)
	kill_all_btn.pressed.connect(_on_kill_all_pressed)

func _on_spawn_pressed() -> void:
	if game == null:
		return
	var idx = enemy_dropdown.selected
	if idx < 0 or idx >= available_enemies.size():
		return
	var enemy_data = available_enemies[idx]
	var qty = int(quantity_spin.value)
	
	for i in qty:
		# Spawna con un piccolo delay tra uno e l'altro
		await get_tree().create_timer(0.2).timeout
		if game.has_method("spawn_enemy"):
			game.spawn_enemy(enemy_data)

func _on_gold_pressed() -> void:
	if game == null:
		return
	game.gold += 100
	if game.tower_shop:
		game.tower_shop.refresh_gold(game.gold)

func _on_kill_all_pressed() -> void:
	for enemy in get_tree().get_nodes_in_group("enemies"):
		if enemy.has_method("die"):
			enemy.die()

extends Node2D

@export var groundLayer: TileMapLayer
@export var itemScenes: Array[PackedScene] = []

@export var maxItemsInMap: int = 20
@export var spawnInterval: float = 2.0
@export var itemParent: Node2D

var spawnTimer: Timer


func _ready() -> void:
	randomize()
	PlayerData.current_context = "lobby"

	if itemParent == null:
		itemParent = self

	spawnTimer = Timer.new()
	spawnTimer.wait_time = spawnInterval
	spawnTimer.autostart = true
	spawnTimer.timeout.connect(_on_spawn_timer_timeout)
	add_child(spawnTimer)

	# Riempie subito la mappa fino al massimo
	while getCurrentItemCount() < maxItemsInMap:
		spawnOneRandomItem()


func _on_spawn_timer_timeout() -> void:
	if getCurrentItemCount() < maxItemsInMap:
		spawnOneRandomItem()


func getCurrentItemCount() -> int:
	return get_tree().get_nodes_in_group("ground_items").size()


func spawnOneRandomItem() -> void:
	if groundLayer == null:
		print("Ground layer non assegnato")
		return

	if itemScenes.is_empty():
		print("Nessun item assegnato")
		return

	var validCells: Array[Vector2i] = groundLayer.get_used_cells()

	if validCells.is_empty():
		print("Nessuna tile trovata nel layer Ground")
		return

	validCells.shuffle()

	for cell in validCells:
		if isCellFree(cell):
			var randomScene = itemScenes[randi() % itemScenes.size()]
			var item = randomScene.instantiate()

			var localPos = groundLayer.map_to_local(cell)
			item.global_position = groundLayer.to_global(localPos)

			item.add_to_group("ground_items")

			# z ordering fisso
			item.z_index = 1

			itemParent.add_child(item)
			return


func isCellFree(cell: Vector2i) -> bool:
	var targetPos = groundLayer.to_global(groundLayer.map_to_local(cell))

	for item in get_tree().get_nodes_in_group("ground_items"):
		if item.global_position.distance_to(targetPos) < 4.0:
			return false

	return true

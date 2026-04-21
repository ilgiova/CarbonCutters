extends Node2D

@export var groundLayer: TileMapLayer
@export var itemScenes: Array[PackedScene] = []
@export var maxItemsInMap: int = 15
@export var itemParent: Node2D
@onready var player: CharacterBody2D = $"Y-sorted/player"

func _ready() -> void:
	randomize()
	print(player.global_position)
	PlayerData.current_context = "lobby"
	add_to_group("item_spawner")

	if itemParent == null:
		itemParent = self

	while getCurrentItemCount() < maxItemsInMap:
		spawnOneRandomItem()

func getCurrentItemCount() -> int:
	return get_tree().get_nodes_in_group("ground_items").size()

func spawnOneRandomItem() -> void:
	if getCurrentItemCount() >= maxItemsInMap:
		return

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
			var randomScene: PackedScene = itemScenes[randi() % itemScenes.size()]
			var item = randomScene.instantiate()

			var localPos: Vector2 = groundLayer.map_to_local(cell)
			item.global_position = groundLayer.to_global(localPos)

			item.add_to_group("ground_items")
			item.z_index = 1

			itemParent.add_child(item)
			return

func isCellFree(cell: Vector2i) -> bool:
	var targetPos = groundLayer.to_global(groundLayer.map_to_local(cell))

	for item in get_tree().get_nodes_in_group("ground_items"):
		if item.global_position.distance_to(targetPos) < 4.0:
			return false

	return true

func on_item_collected() -> void:
	call_deferred("_respawn_if_needed")

func _respawn_if_needed() -> void:
	if getCurrentItemCount() < maxItemsInMap:
		spawnOneRandomItem()

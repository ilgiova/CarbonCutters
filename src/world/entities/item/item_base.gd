extends Area2D

enum ItemType {
	PLASTIC,
	CARDBOARD,
	GLASS,
	ALUMINUM,
	ORGANIC
}

@export var itemType: ItemType

func _ready() -> void:
	y_sort_enabled = true
	add_to_group("items")

func collect() -> void:
	PlayerData.addItem(itemType)
	
	var spawner = get_tree().get_first_node_in_group("item_spawner")

	queue_free()

	if spawner != null:
		spawner.call_deferred("on_item_collected")

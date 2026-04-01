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
	add_to_group("items")

func collect() -> void:
	PlayerData.addItem(itemType)
	queue_free()

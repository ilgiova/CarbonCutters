extends BasePickup

@export var heal_amount: int = 20

func _on_collected(collector: Node2D) -> void:
	if collector.has_method("heal"):
		collector.heal(heal_amount)

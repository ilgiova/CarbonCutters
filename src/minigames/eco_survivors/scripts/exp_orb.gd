extends BasePickup

@export var exp_value: int = 1

func _on_collected(collector: Node2D) -> void:
	if collector.has_method("gain_exp"):
		collector.gain_exp(exp_value)

func set_exp_value(value: int) -> void:
	exp_value = value

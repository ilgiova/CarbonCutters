extends PanelContainer

signal upgrade_requested
signal sell_requested

@onready var tower_image  : TextureRect = $MarginContainer/VBoxContainer/TowerImage
@onready var tower_name   : Label       = $MarginContainer/VBoxContainer/TowerName
@onready var description  : Label       = $MarginContainer/VBoxContainer/Description
@onready var value_dmg    : Label       = $MarginContainer/VBoxContainer/StatsContainer/DamageRow/LabelDmg
@onready var value_dps    : Label       = $MarginContainer/VBoxContainer/StatsContainer/DpsRow/LabelDps
@onready var value_range  : Label       = $MarginContainer/VBoxContainer/StatsContainer/RangeRow/LabelRange
@onready var value_speed  : Label       = $MarginContainer/VBoxContainer/StatsContainer/SpeedRow/LabelSpeed
@onready var upgrade_btn  : TextureButton      = $MarginContainer/VBoxContainer/HBoxContainer/UpgradeBtn
@onready var upgrade_btn_label  : Label      = $MarginContainer/VBoxContainer/HBoxContainer/UpgradeBtn/Label
@onready var sell_btn: TextureButton = $MarginContainer/VBoxContainer/HBoxContainer2/DeleteBtn

var _current_tower: Node = null
var _current_data: TowerData = null
var _tower_placed: bool = false

func _ready() -> void:
	sell_btn.pressed.connect(_on_delete_btn_pressed)
	visible = false
	upgrade_btn.pressed.connect(func(): upgrade_requested.emit())

func show_for(data: TowerData, placed: bool = false, tower: Node = null) -> void:
	if _current_tower and is_instance_valid(_current_tower):
		_current_tower.set_range_visible(false)
	_current_tower = tower
	if _current_tower:
		_current_tower.set_range_visible(true)
	_current_data = data
	_tower_placed = placed
	_refresh(data, placed)
	visible = true

func hide_popup() -> void:
	if _current_tower and is_instance_valid(_current_tower):
		_current_tower.set_range_visible(false)
	_current_tower = null
	_current_data = null
	visible = false

func _refresh(data: TowerData, placed: bool) -> void:
	tower_image.texture = data.texture
	tower_name.text     = tr(data.tower_name)        # ← tr()
	description.text    = tr(data.description)        # ← tr()
	value_dmg.text      = tr("DAMAGE")+": %.0f" % data.damage
	value_dps.text      = "DPS: %.1f" % data.get_dps()
	value_range.text    = tr("RANGE") + ": %.0f" % data.attack_range
	value_speed.text    = tr("CADENCE")+": %.1fs" % data.attack_cooldown
	if data.upgrade == null:
		upgrade_btn_label.text     = tr("ECO_VALLEY_TOWER_MAX_LEVEL")
		upgrade_btn.disabled = true
	else:
		upgrade_btn_label.text    = tr("ECO_VALLEY_TOWER_UPGRADE") + "  %d" % data.upgrade_cost
		upgrade_btn.disabled = not placed



func _on_upgrade_btn_pressed() -> void:
	upgrade_requested.emit()
	


func _on_delete_btn_pressed() -> void:
	print("DELETE")
	sell_requested.emit()

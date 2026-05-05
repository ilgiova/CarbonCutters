extends PanelContainer

signal tower_selected(data: TowerData)

@onready var card_list  = $HBoxContainer/MarginContainer/ScrollContainer/CardList
@onready var scroll     = $HBoxContainer/MarginContainer/ScrollContainer
@onready var info_popup = $"../TowerInfoPopup"

const WIDTH_SLIM := 36.0
const WIDTH_OPEN := 140.0
const ANIM_SPEED := 12.0

var _current_gold: int = 0
var _selected_card: Control = null
var _available_towers: Array[TowerData] = []

func _ready() -> void:
	offset_left  = -WIDTH_SLIM
	offset_right = 0.0
	card_list.visible = false
	scroll.size_flags_horizontal = SIZE_EXPAND_FILL
	scroll.size_flags_vertical   = SIZE_EXPAND_FILL

func setup(towers: Array[TowerData], gold: int) -> void:
	_available_towers = towers
	_current_gold     = gold
	_build_cards()

func refresh_gold(gold: int) -> void:
	_current_gold = gold
	_rebuild_affordability()

func deselect() -> void:
	if _selected_card and is_instance_valid(_selected_card):
		_selected_card.add_theme_stylebox_override("panel", _selected_card.get_meta("style_normal"))
	_selected_card = null
	info_popup.hide_popup()

func show_placed_tower(data: TowerData, tower: Node) -> void:
	if _selected_card and is_instance_valid(_selected_card):
		_selected_card.add_theme_stylebox_override("panel", _selected_card.get_meta("style_normal"))
	_selected_card = null
	info_popup.show_for(data, true, tower)

func _process(delta: float) -> void:
	var mouse_x := get_global_mouse_position().x
	var screen_w := get_viewport_rect().size.x
	var on_shop:  bool = mouse_x >= screen_w - WIDTH_OPEN
	var hovering: bool = on_shop or _selected_card != null
	var target_w := WIDTH_OPEN if hovering else WIDTH_SLIM
	var current_w := -offset_left
	var new_w     := lerpf(current_w, target_w, ANIM_SPEED * delta)
	offset_left           = -new_w
	custom_minimum_size.x = new_w
	card_list.visible     = new_w > WIDTH_SLIM + 20.0

func _build_cards() -> void:
	for child in card_list.get_children():
		child.queue_free()
	for data in _available_towers:
		card_list.add_child(_make_card(data))

func _make_card(data: TowerData) -> PanelContainer:
	var card := PanelContainer.new()
	card.custom_minimum_size = Vector2(WIDTH_OPEN - 16, 0)
	card.set_meta("tower_data", data)

	var sn := StyleBoxFlat.new()
	sn.bg_color     = Color(0.1, 0.1, 0.1, 0.85)
	sn.border_color = Color(0.4, 0.4, 0.4, 0.6)
	sn.set_border_width_all(1)
	sn.set_corner_radius_all(6)
	card.set_meta("style_normal", sn)

	var ss := StyleBoxFlat.new()
	ss.bg_color     = Color(0.05, 0.22, 0.08, 0.95)
	ss.border_color = Color(0.2, 0.9, 0.35)
	ss.set_border_width_all(2)
	ss.set_corner_radius_all(6)
	ss.shadow_color = Color(0.2, 0.9, 0.35, 0.4)
	ss.shadow_size  = 4
	card.set_meta("style_selected", ss)

	card.add_theme_stylebox_override("panel", sn)

	var vbox := VBoxContainer.new()
	vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	vbox.add_theme_constant_override("separation", 2)
	card.add_child(vbox)

	if data.texture != null:
		var tex_rect := TextureRect.new()
		tex_rect.texture             = data.texture
		tex_rect.custom_minimum_size = Vector2(36, 36)
		tex_rect.stretch_mode        = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		tex_rect.expand_mode         = TextureRect.EXPAND_FIT_WIDTH_PROPORTIONAL
		vbox.add_child(tex_rect)
	else:
		var icon := Label.new()
		icon.text                = "🏰"
		icon.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		icon.add_theme_font_size_override("font_size", 20)
		vbox.add_child(icon)

	var name_lbl := Label.new()
	name_lbl.text                = data.tower_name
	name_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	name_lbl.add_theme_font_size_override("font_size", 9)
	name_lbl.clip_text           = true
	vbox.add_child(name_lbl)

	var cost_lbl := Label.new()
	cost_lbl.text                = "%d" % data.cost
	cost_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	cost_lbl.add_theme_font_size_override("font_size", 10)
	cost_lbl.set_meta("is_cost_label", true)
	vbox.add_child(cost_lbl)

	card.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	card.gui_input.connect(func(event):
		if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
			_on_card_pressed(card, data)
	)

	_apply_affordability(card, _current_gold)
	return card

func _on_card_pressed(card: PanelContainer, data: TowerData) -> void:
	if _current_gold < data.cost:
		return
	if _selected_card == card:
		deselect()
		tower_selected.emit(null)
		return
	deselect()
	_selected_card = card
	card.add_theme_stylebox_override("panel", card.get_meta("style_selected"))
	tower_selected.emit(data)
	info_popup.show_for(data, false)

func _rebuild_affordability() -> void:
	for card in card_list.get_children():
		_apply_affordability(card, _current_gold)

func _apply_affordability(card: PanelContainer, gold: int) -> void:
	var data: TowerData = card.get_meta("tower_data")
	var can := gold >= data.cost
	card.modulate = Color.WHITE if can else Color(0.5, 0.5, 0.5, 0.8)
	for child in card.get_child(0).get_children():
		if child.has_meta("is_cost_label"):
			child.modulate = Color.WHITE if can else Color(1.0, 0.3, 0.3)
	if not can and _selected_card == card:
		deselect()

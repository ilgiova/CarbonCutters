extends Node2D

signal player_hp_changed(new_hp: int)
signal player_defeated

@onready var path             = $Path2D
@onready var towers_container = $Towers
@onready var tower_shop       = $UI/Root/tower_shop
@onready var coint_label      = $UI/Points/Label
@onready var tilemap_path       = $Tile/Path
@onready var tilemap_decoration = $Tile/Decoration
@onready var tilemap_bridge     = $Tile/Bridge
@onready var tilemap_water      = $Tile/water
@onready var tilemap_foam       = $Tile/Foam
@onready var round_ui = $UI/RoundInfo
@onready var wave_manager = $WaveManager

@export var enemy_scene:      PackedScene
@export var tower_scene:      PackedScene
@export var available_towers: Array[TowerData] = []

var gold: int = 300
var placing := false
var preview: Node2D = null
var selected_data: TowerData = null
var _selected_tower: Node = null
var player_hp: int = 100
const MAX_PLAYER_HP: int = 100

# ---------------------------------------------------------------------------
# Lifecycle
# ---------------------------------------------------------------------------

func _ready() -> void:
	tower_shop.setup(available_towers, gold)
	tower_shop.tower_selected.connect(_on_tower_selected)
	tower_shop.info_popup.upgrade_requested.connect(_on_upgrade_requested)
	tower_shop.info_popup.sell_requested.connect(_on_sell_requested)
	round_ui.setup(wave_manager, self)   # ← serve il "self"
	# Collega il pannello debug se presente nella scena
	var debug = get_node_or_null("UI/DebugSpawner")
	if debug:
		debug.game = self

func _process(_delta: float) -> void:
	if placing and preview:
		var mouse_pos = get_global_mouse_position()
		preview.global_position = mouse_pos
		
		if _is_valid_placement(mouse_pos):
			preview.modulate = Color(1, 1, 1, 0.55)
		else:
			preview.modulate = Color(1, 0.2, 0.2, 0.55)
	
	coint_label.text = "Coints: " + str(gold)

# ---------------------------------------------------------------------------
# Spawn nemici
# ---------------------------------------------------------------------------

func spawn_enemy(enemy_data: EnemyData = null, hp_mult: float = 1.0, speed_mult: float = 1.0) -> void:
	var enemy = enemy_scene.instantiate()
	var pf = PathFollow2D.new()
	pf.rotates = false
	pf.loop = false   # ← aggiungi questa riga
	path.add_child(pf)
	pf.progress = 0
	pf.add_child(enemy)
	enemy.path_follow = pf
	
	enemy.hp_multiplier = hp_mult
	enemy.speed_multiplier = speed_mult
	
	if enemy_data != null:
		enemy.apply_data(enemy_data)
	
	enemy.enemy_died.connect(_on_enemy_died)
	enemy.reached_end.connect(_on_enemy_reached_end)

func _on_enemy_died(reward: int) -> void:
	gold += reward
	tower_shop.refresh_gold(gold)

func _on_enemy_reached_end(damage: int) -> void:
	player_hp = max(0, player_hp - damage)
	player_hp_changed.emit(player_hp)
	print(player_hp)
	if player_hp <= 0:
		player_defeated.emit()
		print("GAME OVER!")

# Per il boss: spawna nemici minori alla morte (Fase 7)
func spawn_death_enemies(spawn_data: Dictionary) -> void:
	for enemy_data in spawn_data.enemies:
		spawn_enemy(enemy_data)
		var children = path.get_children()
		var last_pf = children[children.size() - 1]
		if last_pf is PathFollow2D:
			last_pf.progress = spawn_data.path_progress

# ---------------------------------------------------------------------------
# Selezione e piazzamento torri
# ---------------------------------------------------------------------------

func _on_tower_selected(data: TowerData) -> void:
	if data == null:
		cancel_placing()
	else:
		_start_placing(data)

func _start_placing(data: TowerData) -> void:
	if preview:
		preview.queue_free()
		preview = null
	if gold < data.cost:
		tower_shop.deselect()
		return
	selected_data = data
	placing = true
	preview = tower_scene.instantiate()
	add_child(preview)
	preview.apply_data(data)
	preview.z_index = 10
	preview.modulate = Color(1, 1, 1, 0.55)
	preview.set_range_visible(true)
	var sprite = preview.get_node_or_null("Sprite2D")
	if sprite:
		sprite.scale = Vector2(0.15, 0.15)
	var click = preview.get_node_or_null("ClickArea")
	if click:
		click.input_pickable = false
	var area = preview.get_node_or_null("RangeArea")
	if area:
		area.monitoring     = false
		area.monitorable    = false
		area.input_pickable = false

func cancel_placing() -> void:
	if preview:
		preview.queue_free()
		preview = null
	placing = false
	selected_data = null
	tower_shop.deselect()

func _place_tower(pos: Vector2) -> void:
	if not _is_valid_placement(pos):
		return
	gold -= selected_data.cost
	var tower = tower_scene.instantiate()
	towers_container.add_child(tower)
	tower.apply_data(selected_data)
	tower.global_position = pos
	tower.tower_clicked.connect(_on_placed_tower_clicked)
	preview.queue_free()
	preview = null
	placing = false
	selected_data = null
	tower_shop.deselect()
	tower_shop.refresh_gold(gold)

func _on_placed_tower_clicked(tower: Node) -> void:
	if placing:
		return
	if _selected_tower == tower:
		_selected_tower = null
		tower_shop.deselect()
		return
	_selected_tower = tower
	tower_shop.show_placed_tower(tower.data, tower)

# ---------------------------------------------------------------------------
# Upgrade e vendita torre
# ---------------------------------------------------------------------------

func _on_upgrade_requested() -> void:
	if _selected_tower == null or not is_instance_valid(_selected_tower):
		return
	var cost = _selected_tower.data.upgrade_cost
	if gold < cost:
		return
	if _selected_tower.try_upgrade(gold):
		gold -= cost
		tower_shop.refresh_gold(gold)
		tower_shop.info_popup.show_for(_selected_tower.data, true, _selected_tower)

func _on_sell_requested() -> void:
	if _selected_tower == null or not is_instance_valid(_selected_tower):
		return
	var refund = int(_selected_tower.data.cost * 0.5)
	gold += refund
	tower_shop.refresh_gold(gold)
	_selected_tower.queue_free()
	_selected_tower = null
	tower_shop.deselect()

# ---------------------------------------------------------------------------
# Input
# ---------------------------------------------------------------------------

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		if not placing:
			var popup = tower_shop.info_popup
			if popup.visible:
				var shop_rect  = tower_shop.get_global_rect()
				var popup_rect = popup.get_global_rect()
				if not shop_rect.has_point(event.position) and not popup_rect.has_point(event.position):
					_selected_tower = null
					tower_shop.deselect()
			return
	if not placing:
		return
	if event is InputEventMouseButton and event.pressed:
		match event.button_index:
			MOUSE_BUTTON_LEFT:
				var shop_rect = tower_shop.get_global_rect()
				if not shop_rect.has_point(event.position):
					_place_tower(get_global_mouse_position())
					get_viewport().set_input_as_handled()
			MOUSE_BUTTON_RIGHT:
				cancel_placing()
				get_viewport().set_input_as_handled()

# ---------------------------------------------------------------------------
# Validazione piazzamento
# ---------------------------------------------------------------------------

func _is_valid_placement(world_pos: Vector2) -> bool:
	var cell_path   = tilemap_path.local_to_map(tilemap_path.to_local(world_pos))
	var cell_water  = tilemap_water.local_to_map(tilemap_water.to_local(world_pos))
	var cell_deco   = tilemap_decoration.local_to_map(tilemap_decoration.to_local(world_pos))
	var cell_bridge = tilemap_bridge.local_to_map(tilemap_bridge.to_local(world_pos))
	var cell_foam   = tilemap_foam.local_to_map(tilemap_foam.to_local(world_pos))
	
	if tilemap_path.get_cell_source_id(cell_path) != -1:
		return false
	if tilemap_decoration.get_cell_source_id(cell_deco) != -1:
		return false
	if tilemap_bridge.get_cell_source_id(cell_bridge) != -1:
		return false
	if tilemap_foam.get_cell_source_id(cell_foam) != -1:
		return true
	if tilemap_water.get_cell_source_id(cell_water) != -1:
		return false
	
	for tower in towers_container.get_children():
		var tower_cell = tilemap_path.local_to_map(tilemap_path.to_local(tower.global_position))
		if tower_cell == cell_path:
			return false
	
	return true

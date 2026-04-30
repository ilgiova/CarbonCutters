extends CanvasLayer

@export var player: Node2D
@export var tilemap: Node
@export var poi_container: Node2D

@onready var markers_container = $WorldMap/MarginContainer/SubViewportContainer/SubViewport/Markers
@onready var viewport = $MiniMap/SubViewportContainer/SubViewport
@onready var minimap_camera = $MiniMap/SubViewportContainer/SubViewport/Camera2D
@onready var minimap = $MiniMap
@onready var canvas = $"."

@onready var worldmap = $WorldMap
@onready var worldmap_viewport = $WorldMap/MarginContainer/SubViewportContainer/SubViewport
@onready var worldmap_camera = $WorldMap/MarginContainer/SubViewportContainer/SubViewport/Camera2D

var MARKERS_OFFSET: Vector2 = Vector2(-90, -45)

func _ready():
	canvas.visible = true
	process_mode = Node.PROCESS_MODE_ALWAYS
	
	await get_tree().process_frame
	
	viewport.world_2d = get_viewport().world_2d

	if player == null:
		player = get_tree().get_first_node_in_group("player")

	worldmap.visible = false
	worldmap_viewport.world_2d = get_viewport().world_2d

	if tilemap == null:
		tilemap = get_tree().get_first_node_in_group("tilemap")

	if tilemap != null:
		setup_worldmap_camera()
	markers_container.visible = false;

func _process(_delta):
	if player != null:
		minimap_camera.global_position = player.global_position

	if worldmap.visible and has_node("WorldMap/PlayerIcon") and player != null:
		var pos = world_to_map(player.global_position)
		var icon = $WorldMap/PlayerIcon
		
		icon.centered = true
		icon.global_position = pos + Vector2(3, -2)

func _unhandled_input(event):
	if InputMap.has_action("map") and event.is_action_pressed("map"):
		worldmap.visible = !worldmap.visible
		minimap.visible = !minimap.visible
		if(!worldmap.visible):
			markers_container.visible = false;
		else:
			markers_container.visible = true;
		if worldmap.visible:
			update_markers()
		
		get_tree().paused = worldmap.visible

func setup_worldmap_camera():
	var used_rect = tilemap.get_used_rect()
	var tile_size_vec = Vector2(tilemap.tile_set.tile_size)

	var world_size = Vector2(used_rect.size) * tile_size_vec
	var world_origin = Vector2(used_rect.position) * tile_size_vec

	var container = $WorldMap/MarginContainer/SubViewportContainer
	var viewport_size = container.size

	if world_size.x == 0 or world_size.y == 0:
		return
	if viewport_size.x == 0 or viewport_size.y == 0:
		return

	var zoom_x = viewport_size.x / world_size.x
	var zoom_y = viewport_size.y / world_size.y
	var zoom = min(zoom_x, zoom_y)

	zoom = max(zoom, 0.0001)
	zoom *= 0.9

	worldmap_camera.zoom = Vector2(zoom, zoom)
	worldmap_camera.position = world_origin + world_size / 2

func world_to_map(world_pos: Vector2) -> Vector2:
	var cam = worldmap_camera
	var container = $WorldMap/MarginContainer/SubViewportContainer
	
	var visible_size = container.size / cam.zoom
	var top_left = cam.position - visible_size / 2
	var normalized = (world_pos - top_left) / visible_size
	
	return container.global_position + normalized * container.size

func update_markers():
	for marker in markers_container.get_children():
		if not "world_position" in marker:
			continue
		
		var world_px = Vector2(marker.world_position) * 64.0
		marker.global_position = world_px + MARKERS_OFFSET

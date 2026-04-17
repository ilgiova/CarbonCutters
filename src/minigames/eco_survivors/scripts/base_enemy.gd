class_name BaseEnemy
extends CharacterBody2D

@export_category("Stats")
@export var movement_speed: float = 200.0
@export var damage: int = 10
@export var max_health: int = 30
@export var exp_value: int = 1

@export_category("Drops")
@export var exp_scene: PackedScene
@export var potion_scene: PackedScene

var potion_drop_chance: float = 0.08
const FLASH_DURATION: float = 0.2
var current_health: int

# Variabile fortemente tipizzata per garantire che accetti solo oggetti fisici nello spazio 2D
var _player: Node2D = null

func _ready() -> void:
	add_to_group("enemy")
	current_health = max_health
	
	# Usiamo la nostra funzione dedicata invece di prendere ciecamente il primo nodo
	_find_player()

func _physics_process(_delta: float) -> void:
	# Verifichiamo se il player esiste ancora o è stato distrutto
	if not is_instance_valid(_player):
		_find_player()
		# Se dopo la ricerca il player non c'è, interrompiamo l'esecuzione del frame
		if _player == null:
			return
			
	# Calcolo del vettore di direzione normalizzato verso il bersaglio
	var direction := global_position.direction_to(_player.global_position)
	velocity = direction * movement_speed
	
	# Gestione del flip dello sprite basata sulla direzione sull'asse X
	if velocity.x != 0.0:
		$Sprite2D.flip_h = velocity.x > 0.0
		
	move_and_slide()

# Cerca nel gruppo "player" e filtra solo i nodi validi (Node2D o derivati)
func _find_player() -> void:
	var nodes = get_tree().get_nodes_in_group("player")
	for node in nodes:
		if node is Node2D:
			_player = node
			return
	_player = null

func take_damage(amount: int) -> void:
	# clamp assicura che gli HP non scendano sotto lo zero
	current_health = clampi(current_health - amount, 0, max_health)
	flash_red()
	if current_health <= 0:
		die()

func flash_red() -> void:
	# Casting sicuro per evitare crash se lo Sprite2D manca
	var sprite := get_node_or_null("Sprite2D") as Sprite2D
	if sprite == null:
		return
		
	sprite.modulate = Color.RED
	await get_tree().create_timer(FLASH_DURATION).timeout
	
	# Controllo di validità prima di resettare, il nemico potrebbe essere morto nel frattempo
	if is_instance_valid(sprite):
		sprite.modulate = Color.WHITE

func die() -> void:
	PlayerData.add_score(5)
	# call_deferred assicura che l'istanza dei drop avvenga in un momento sicuro per il physics engine
	call_deferred("_spawn_drops")
	queue_free()

func _spawn_drops() -> void:
	var scene_root := get_tree().current_scene
	
	# Spawn del globo di esperienza
	if exp_scene:
		var orb := exp_scene.instantiate()
		scene_root.add_child(orb)
		orb.global_position = global_position
		if orb.has_method("set_exp_value"):
			orb.set_exp_value(exp_value)
			
	# Roll probabilistico per il drop della pozione
	if potion_scene and randf() < potion_drop_chance:
		var potion := potion_scene.instantiate()
		scene_root.add_child(potion)
		potion.global_position = global_position

func _on_hitbox_body_entered(body: Node2D) -> void:
	# Duck typing: controlliamo solo se il nodo ha il metodo, senza preoccuparci della sua classe esatta
	if body.is_in_group("player"):
		if body.has_method("take_damage"):
			body.take_damage(damage)
		explode()

func explode() -> void:
	queue_free()

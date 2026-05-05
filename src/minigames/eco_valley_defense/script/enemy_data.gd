class_name EnemyData
extends Resource

@export var enemy_name: String = "Nemico"
@export var texture: Texture2D
@export var sprite_frames: SpriteFrames  # opzionale, se usi animazioni

# Stats
@export var max_hp: float = 50.0
@export var speed: float = 100.0
@export var damage_to_castle: int = 1   # quanti HP toglie al castello se arriva in fondo
@export var gold_reward: int = 10        # oro che dà quando muore

# Livello: 1 = base, 5 = boss
@export var level: int = 1

# Solo per il boss: cosa spawna alla morte
@export var death_spawn: Array[EnemyData] = []

# Scala visiva del nemico (utile per differenziare i tier visivamente)
@export var scale_multiplier: float = 0.1

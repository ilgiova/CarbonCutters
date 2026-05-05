class_name TowerData
extends Resource

enum AttackType {
	SINGLE_TARGET,  # Colpisce il primo nemico in range (laser/proiettile singolo)
	MULTI_LASER,    # Colpisce più nemici contemporaneamente (fino a num_targets)
	AREA,            # Danno ad area a tutti i nemici in range
	SINGLE_DOT,
	AREA_SLOW 
}

@export var tower_name: String = "Torre"
@export var description: String = "Una torre difensiva."
@export var texture: Texture2D
@export var cost: int = 100
@export var damage: float = 10.0
@export var attack_range: float = 150.0
@export var attack_cooldown: float = 1.0
@export var upgrade: TowerData = null
@export var upgrade_cost: int = 150
# --- DOT (Damage Over Time) ---
@export var dot_damage: float = 0.0           # danno per tick
@export var dot_duration: float = 0.0          # durata totale del veleno
@export var dot_tick_interval: float = 1.0     # ogni quanti secondi infligge il tick
# --- Configurazione attacco ---
@export var attack_type: AttackType = AttackType.SINGLE_TARGET
@export var num_targets: int = 1  # Per MULTI_LASER: quanti nemici colpisce contemporaneamente

# --- Scene degli effetti visivi ---
@export var attack_effect_scene: PackedScene  # Laser, proiettile o effetto area
@export var effect_color: Color = Color(1, 1, 0, 1)  # Colore personalizzabile

# --- Slow (per AREA_SLOW) ---
@export var slow_amount: float = 0.0       # 0.3 = -30% velocità
@export var slow_duration: float = 0.0     # secondi di durata

## DPS calcolato automaticamente
func get_dps() -> float:
	return damage / attack_cooldown

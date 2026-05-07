# Enemy wave configuration
# Enemy HP scaling and damage parameters

class_name EnemyData

extends RefCounted


# === Base Enemy Parameters ===

const BASE_ENEMY_HP: int = 46
const ENEMY_HP_PER_THREAT: int = 26
const ENEMY_HP_PER_WAVE: int = 14


# === Damage Parameters ===

const BASE_ENEMY_DAMAGE: int = 5
const ENEMY_DAMAGE_PER_THREAT: int = 4
const ENEMY_DAMAGE_PER_WAVE: int = 1


# === Wave Instance State ===

var threat: int = 1
var wave: int = 1
var hp: int = 0
var max_hp: int = 0


func setup(route_threat: int, current_wave: int) -> void:
	threat = route_threat
	wave = current_wave
	max_hp = calculate_max_hp()
	hp = max_hp


func calculate_max_hp() -> int:
	return BASE_ENEMY_HP + threat * ENEMY_HP_PER_THREAT + (wave - 1) * ENEMY_HP_PER_WAVE


func calculate_damage() -> int:
	return BASE_ENEMY_DAMAGE + threat * ENEMY_DAMAGE_PER_THREAT + wave


func take_damage(amount: int) -> void:
	hp = max(0, hp - amount)


func is_defeated() -> bool:
	return hp <= 0


func get_hp_ratio() -> float:
	return float(hp) / float(max(max_hp, 1))


func next_wave() -> void:
	wave += 1
	setup(threat, wave)
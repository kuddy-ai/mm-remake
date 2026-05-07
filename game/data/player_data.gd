# Player character data and state
# Hunter stats and progression

class_name PlayerData

extends RefCounted


# === Initial Values ===

const INITIAL_HUNTER_LEVEL: int = 1
const INITIAL_HUNTER_HP: int = 100
const INITIAL_HUNTER_MAX_HP: int = 100


# === Combat Parameters ===

const BASE_HUNTER_DAMAGE: int = 7
const HUNTER_DAMAGE_PER_LEVEL: int = 3


# === Progression ===

const LEVEL_UP_XP_THRESHOLD: int = 50


# === Instance State ===

var level: int = INITIAL_HUNTER_LEVEL
var hp: int = INITIAL_HUNTER_HP
var max_hp: int = INITIAL_HUNTER_MAX_HP
var xp: int = 0


func reset() -> void:
	level = INITIAL_HUNTER_LEVEL
	hp = INITIAL_HUNTER_HP
	max_hp = INITIAL_HUNTER_MAX_HP
	xp = 0


func calculate_damage() -> int:
	return BASE_HUNTER_DAMAGE + level * HUNTER_DAMAGE_PER_LEVEL


func take_damage(amount: int) -> void:
	hp = max(0, hp - amount)


func heal(amount: int) -> void:
	hp = min(max_hp, hp + amount)


func full_heal() -> void:
	hp = max_hp


func add_xp(amount: int) -> bool:
	xp += amount
	if xp >= LEVEL_UP_XP_THRESHOLD:
		level += 1
		xp = 0
		full_heal()
		return true
	return false


func is_alive() -> bool:
	return hp > 0


func get_hp_ratio() -> float:
	return float(hp) / float(max(max_hp, 1))
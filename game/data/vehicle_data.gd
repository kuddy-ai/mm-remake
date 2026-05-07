# Vehicle (tank) data and state
# Tank armor, cannon, and upgrade progression

class_name VehicleData

extends RefCounted


# === Initial Values ===

const INITIAL_TANK_LEVEL: int = 1
const INITIAL_TANK_ARMOR: int = 120
const INITIAL_TANK_MAX_ARMOR: int = 120
const INITIAL_CANNON_LEVEL: int = 1


# === Upgrade Effects ===

const TANK_ARMOR_GAIN: int = 35
const TANK_LEVEL_GAIN: int = 1
const CANNON_LEVEL_GAIN: int = 1


# === Combat Parameters ===

const BASE_CANNON_DAMAGE: int = 18
const CANNON_DAMAGE_PER_LEVEL: int = 8
const CANNON_DAMAGE_PER_TANK_LEVEL: int = 4


# === Failure Recovery ===

const MIN_FAIL_TANK_ARMOR: int = 40
const MIN_FAIL_TANK_ARMOR_RATIO: float = 0.5


# === Instance State ===

var tank_level: int = INITIAL_TANK_LEVEL
var armor: int = INITIAL_TANK_ARMOR
var max_armor: int = INITIAL_TANK_MAX_ARMOR
var cannon_level: int = INITIAL_CANNON_LEVEL


func reset() -> void:
	tank_level = INITIAL_TANK_LEVEL
	armor = INITIAL_TANK_ARMOR
	max_armor = INITIAL_TANK_MAX_ARMOR
	cannon_level = INITIAL_CANNON_LEVEL


func calculate_cannon_damage() -> int:
	return BASE_CANNON_DAMAGE + cannon_level * CANNON_DAMAGE_PER_LEVEL + tank_level * CANNON_DAMAGE_PER_TANK_LEVEL


func take_damage(amount: int) -> void:
	armor = max(0, armor - amount)


func repair(amount: int) -> void:
	armor = min(max_armor, armor + amount)


func full_repair() -> void:
	armor = max_armor


func upgrade_armor() -> void:
	tank_level += TANK_LEVEL_GAIN
	max_armor += TANK_ARMOR_GAIN
	armor = max_armor


func upgrade_cannon() -> void:
	cannon_level += CANNON_LEVEL_GAIN


func recover_from_failure() -> void:
	armor = int(max(MIN_FAIL_TANK_ARMOR, max_armor * MIN_FAIL_TANK_ARMOR_RATIO))


func is_operational() -> bool:
	return armor > 0


func get_armor_ratio() -> float:
	return float(armor) / float(max(max_armor, 1))


func get_bonus_scrap() -> int:
	return tank_level * 5
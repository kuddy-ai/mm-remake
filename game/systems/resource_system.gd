# Resource system - handles scrap, fuel, rations
# Separated from UI for maintainability

class_name ResourceSystem

extends RefCounted


# === Signals ===

signal scrap_changed(amount: int, delta: int)
signal fuel_changed(amount: int, delta: int)
signal rations_changed(amount: int, delta: int)


# === Initial Values ===

const INITIAL_SCRAP: int = 120
const INITIAL_FUEL: int = 48
const INITIAL_RATIONS: int = 16


# === Upgrade Costs ===

const UPGRADE_COST_TANK: int = 60
const UPGRADE_COST_CANNON: int = 75
const UPGRADE_COST_HUNTER: int = 45
const BUY_FUEL_COST: int = 30
const BUY_FUEL_AMOUNT: int = 20


# === Result Parameters ===

const MIN_FAIL_SCRAP: int = 4
const FAIL_SCRAP_RATIO: float = 0.2
const XP_PER_THREAT: int = 20
const RATIONS_PER_THREAT: int = 1
const BASE_RATIONS_GAIN: int = 2


# === Instance State ===

var scrap: int = INITIAL_SCRAP
var fuel: int = INITIAL_FUEL
var rations: int = INITIAL_RATIONS


func reset() -> void:
	scrap = INITIAL_SCRAP
	fuel = INITIAL_FUEL
	rations = INITIAL_RATIONS


func add_scrap(amount: int) -> void:
	var delta := amount
	scrap += amount
	scrap_changed.emit(scrap, delta)


func spend_scrap(amount: int) -> bool:
	if scrap < amount:
		return false
	scrap -= amount
	scrap_changed.emit(scrap, -amount)
	return true


func can_afford_scrap(amount: int) -> bool:
	return scrap >= amount


func add_fuel(amount: int) -> void:
	fuel += amount
	fuel_changed.emit(fuel, amount)


func spend_fuel(amount: int) -> bool:
	if fuel < amount:
		return false
	fuel -= amount
	fuel_changed.emit(fuel, -amount)
	return true


func can_afford_fuel(amount: int) -> bool:
	return fuel >= amount


func add_rations(amount: int) -> void:
	rations += amount
	rations_changed.emit(rations, amount)


# === Battle Rewards ===

func grant_victory_rewards(route: Dictionary, tank_bonus: int) -> Dictionary:
	var reward_scrap := int(route["reward"]) + tank_bonus
	var reward_xp := int(route["threat"]) * XP_PER_THREAT
	var reward_rations := BASE_RATIONS_GAIN + int(route["threat"]) * RATIONS_PER_THREAT

	add_scrap(reward_scrap)
	add_rations(reward_rations)

	return {
		"scrap": reward_scrap,
		"xp": reward_xp,
		"rations": reward_rations,
	}


func grant_failure_rewards(route: Dictionary) -> Dictionary:
	var reward_scrap := int(max(MIN_FAIL_SCRAP, int(route["reward"]) * FAIL_SCRAP_RATIO))
	var reward_xp := 5

	add_scrap(reward_scrap)

	return {
		"scrap": reward_scrap,
		"xp": reward_xp,
		"rations": 0,
	}


# === Upgrade Helpers ===

func get_upgrade_cost_tank() -> int:
	return UPGRADE_COST_TANK


func get_upgrade_cost_cannon() -> int:
	return UPGRADE_COST_CANNON


func get_upgrade_cost_hunter() -> int:
	return UPGRADE_COST_HUNTER


func get_buy_fuel_cost() -> int:
	return BUY_FUEL_COST


func get_buy_fuel_amount() -> int:
	return BUY_FUEL_AMOUNT


func can_upgrade_tank() -> bool:
	return can_afford_scrap(UPGRADE_COST_TANK)


func can_upgrade_cannon() -> bool:
	return can_afford_scrap(UPGRADE_COST_CANNON)


func can_upgrade_hunter() -> bool:
	return can_afford_scrap(UPGRADE_COST_HUNTER)


func can_buy_fuel() -> bool:
	return can_afford_scrap(BUY_FUEL_COST)
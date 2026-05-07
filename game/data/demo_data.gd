# Static data configuration for demo gameplay
# Pure data extraction from demo_main.gd - no behavior changes

class_name DemoData


# === Route Configuration ===

const ROUTES: Array[Dictionary] = [
	{
		"name": "废弃加油站",
		"threat": 1,
		"fuel": 8,
		"reward": 38,
		"waves": 3,
	},
	{
		"name": "干涸河床",
		"threat": 2,
		"fuel": 12,
		"reward": 62,
		"waves": 4,
	},
	{
		"name": "雷达废墟",
		"threat": 3,
		"fuel": 18,
		"reward": 96,
		"waves": 5,
	},
]


# === Upgrade Costs ===

const UPGRADE_COST_TANK: int = 60
const UPGRADE_COST_CANNON: int = 75
const UPGRADE_COST_HUNTER: int = 45
const BUY_FUEL_COST: int = 30
const BUY_FUEL_AMOUNT: int = 20


# === Upgrade Effects ===

const TANK_ARMOR_GAIN: int = 35
const TANK_LEVEL_GAIN: int = 1
const CANNON_LEVEL_GAIN: int = 1
const HUNTER_LEVEL_GAIN: int = 1


# === Battle Parameters ===

const BASE_ENEMY_HP: int = 46
const ENEMY_HP_PER_THREAT: int = 26
const ENEMY_HP_PER_WAVE: int = 14

const BASE_HUNTER_DAMAGE: int = 7
const HUNTER_DAMAGE_PER_LEVEL: int = 3

const BASE_CANNON_DAMAGE: int = 18
const CANNON_DAMAGE_PER_LEVEL: int = 8
const CANNON_DAMAGE_PER_TANK_LEVEL: int = 4

const BASE_ENEMY_DAMAGE: int = 5
const ENEMY_DAMAGE_PER_THREAT: int = 4
const ENEMY_DAMAGE_PER_WAVE: int = 1

const BATTLE_TICK_INTERVAL: float = 0.72


# === Initial Player State ===

const INITIAL_SCRAP: int = 120
const INITIAL_FUEL: int = 48
const INITIAL_RATIONS: int = 16

const INITIAL_HUNTER_LEVEL: int = 1
const INITIAL_HUNTER_HP: int = 100

const INITIAL_TANK_LEVEL: int = 1
const INITIAL_TANK_ARMOR: int = 120
const INITIAL_TANK_MAX_ARMOR: int = 120

const INITIAL_CANNON_LEVEL: int = 1


# === Result Parameters ===

const MIN_FAIL_SCRAP: int = 4
const FAIL_SCRAP_RATIO: float = 0.2

const XP_PER_THREAT: int = 20
const LEVEL_UP_XP_THRESHOLD: int = 50
const RATIONS_PER_THREAT: int = 1
const BASE_RATIONS_GAIN: int = 2

const SCRAP_PER_TANK_LEVEL: int = 5

const MIN_FAIL_HUNTER_HP: int = 100
const MIN_FAIL_TANK_ARMOR_RATIO: float = 0.5
const MIN_FAIL_TANK_ARMOR: int = 40


# === Helper Methods ===

static func get_route(index: int) -> Dictionary:
	if index < 0 or index >= ROUTES.size():
		return ROUTES[0]
	return ROUTES[index]


static func get_route_count() -> int:
	return ROUTES.size()


static func calculate_enemy_max_hp(threat: int, wave: int) -> int:
	return BASE_ENEMY_HP + threat * ENEMY_HP_PER_THREAT + (wave - 1) * ENEMY_HP_PER_WAVE


static func calculate_hunter_damage(hunter_level: int) -> int:
	return BASE_HUNTER_DAMAGE + hunter_level * HUNTER_DAMAGE_PER_LEVEL


static func calculate_cannon_damage(cannon_level: int, tank_level: int) -> int:
	return BASE_CANNON_DAMAGE + cannon_level * CANNON_DAMAGE_PER_LEVEL + tank_level * CANNON_DAMAGE_PER_TANK_LEVEL


static func calculate_enemy_damage(threat: int, wave: int) -> int:
	return BASE_ENEMY_DAMAGE + threat * ENEMY_DAMAGE_PER_THREAT + wave
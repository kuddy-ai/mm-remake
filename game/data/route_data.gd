# Route configuration data
# Static route definitions for the game

class_name RouteData

extends RefCounted


# === Route Definitions ===

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


static func get_route(index: int) -> Dictionary:
	if index < 0 or index >= ROUTES.size():
		return ROUTES[0]
	return ROUTES[index]


static func get_route_count() -> int:
	return ROUTES.size()


static func can_afford_route(index: int, current_fuel: int) -> bool:
	var route := get_route(index)
	return current_fuel >= int(route["fuel"])


static func get_route_name(index: int) -> String:
	return str(get_route(index)["name"])


static func get_route_display_text(index: int) -> String:
	var r := get_route(index)
	return "%s  威胁%d  燃料-%d  奖励%d" % [r["name"], r["threat"], r["fuel"], r["reward"]]
# Upgrade system - handles garage upgrades
# Coordinates between ResourceSystem and VehicleData/PlayerData

class_name UpgradeSystem

extends RefCounted


# === Signals ===

signal tank_upgraded(level: int, armor: int)
signal cannon_upgraded(level: int)
signal hunter_upgraded(level: int)
signal fuel_purchased(amount: int)
signal upgrade_failed(reason: String)


# === Dependencies ===

var resources: ResourceSystem
var player: PlayerData
var vehicle: VehicleData


func setup(resource_system: ResourceSystem, player_data: PlayerData, vehicle_data: VehicleData) -> void:
	resources = resource_system
	player = player_data
	vehicle = vehicle_data


func upgrade_tank() -> bool:
	if not resources.can_upgrade_tank():
		upgrade_failed.emit("废金属不足")
		return false

	resources.spend_scrap(resources.get_upgrade_cost_tank())
	vehicle.upgrade_armor()
	tank_upgraded.emit(vehicle.tank_level, vehicle.max_armor)
	return true


func upgrade_cannon() -> bool:
	if not resources.can_upgrade_cannon():
		upgrade_failed.emit("废金属不足")
		return false

	resources.spend_scrap(resources.get_upgrade_cost_cannon())
	vehicle.upgrade_cannon()
	cannon_upgraded.emit(vehicle.cannon_level)
	return true


func upgrade_hunter() -> bool:
	if not resources.can_upgrade_hunter():
		upgrade_failed.emit("废金属不足")
		return false

	resources.spend_scrap(resources.get_upgrade_cost_hunter())
	player.level += 1
	player.full_heal()
	hunter_upgraded.emit(player.level)
	return true


func buy_fuel() -> bool:
	if not resources.can_buy_fuel():
		upgrade_failed.emit("废金属不足")
		return false

	resources.spend_scrap(resources.get_buy_fuel_cost())
	resources.add_fuel(resources.get_buy_fuel_amount())
	fuel_purchased.emit(resources.fuel)
	return true


func get_status_text() -> Array:
	return [
		"猎人 Lv.%d / HP %d" % [player.level, player.hp],
		"战车 Lv.%d / 装甲 %d/%d" % [vehicle.tank_level, vehicle.armor, vehicle.max_armor],
		"主炮 Lv.%d" % vehicle.cannon_level,
		"废金属：%d" % resources.scrap,
	]
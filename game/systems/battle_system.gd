# Battle system - handles combat logic
# Separated from UI for maintainability

class_name BattleSystem

extends RefCounted


# === Signals ===

signal wave_completed(wave: int, total_waves: int)
signal battle_victory(route_name: String)
signal battle_failed()
signal damage_dealt(amount: int, is_cannon: bool)
signal damage_received(amount: int, target: String)
signal enemy_hp_changed(current: int, maximum: int)
signal wave_changed(wave: int, total_waves: int)


# === Dependencies ===

var player: PlayerData
var vehicle: VehicleData
var enemy: EnemyData


# === Configuration ===

const BATTLE_TICK_INTERVAL: float = 0.72
const CANNON_FIRE_INTERVAL: float = 0.4  # Every 4 ticks at 0.72s


# === State ===

var is_running: bool = false
var battle_time: float = 0.0
var tick_accumulator: float = 0.0
var total_waves: int = 0
var current_route: Dictionary = {}


func setup(player_data: PlayerData, vehicle_data: VehicleData) -> void:
	player = player_data
	vehicle = vehicle_data


func start_battle(route: Dictionary) -> void:
	current_route = route
	total_waves = int(route["waves"])
	battle_time = 0.0
	tick_accumulator = 0.0
	is_running = true
	enemy = EnemyData.new()
	enemy.setup(int(route["threat"]), 1)
	wave_changed.emit(1, total_waves)
	enemy_hp_changed.emit(enemy.hp, enemy.max_hp)


func update(delta: float) -> Dictionary:
	if not is_running:
		return {"status": "idle"}

	battle_time += delta
	tick_accumulator += delta

	if tick_accumulator < BATTLE_TICK_INTERVAL:
		return {"status": "running", "time": battle_time}

	tick_accumulator = 0.0
	return _process_combat_tick()


func _process_combat_tick() -> Dictionary:
	var result: Dictionary = {"status": "running", "time": battle_time}

	# Calculate damage
	var hunter_damage := player.calculate_damage()
	var cannon_damage := vehicle.calculate_cannon_damage()
	var use_cannon := int(battle_time * 10.0) % 4 == 0

	var total_damage := hunter_damage
	var log_line := "猎人点射造成 %d 伤害。" % hunter_damage

	if use_cannon:
		total_damage += cannon_damage
		log_line = "主炮开火，合计造成 %d 伤害。" % total_damage
		damage_dealt.emit(total_damage, true)
	else:
		damage_dealt.emit(hunter_damage, false)

	enemy.take_damage(total_damage)
	enemy_hp_changed.emit(enemy.hp, enemy.max_hp)
	result["damage"] = total_damage
	result["log"] = log_line
	result["is_cannon"] = use_cannon

	# Check enemy defeated
	if enemy.is_defeated():
		result["log"] += "\n第 %d 波目标清除。" % enemy.wave

		if enemy.wave >= total_waves:
			is_running = false
			result["status"] = "victory"
			battle_victory.emit(str(current_route["name"]))
			return result

		enemy.next_wave()
		wave_changed.emit(enemy.wave, total_waves)
		enemy_hp_changed.emit(enemy.hp, enemy.max_hp)
		wave_completed.emit(enemy.wave - 1, total_waves)
		result["wave"] = enemy.wave
		return result

	# Enemy attacks back
	var incoming := enemy.calculate_damage()

	if enemy.wave % 2 == 0:
		vehicle.take_damage(incoming)
		damage_received.emit(incoming, "tank")
		result["log"] += "\n敌群撕咬履带，装甲 -%d。" % incoming
		result["target"] = "tank"
	else:
		var hunter_hit := max(2, incoming - 3)
		player.take_damage(hunter_hit)
		damage_received.emit(hunter_hit, "hunter")
		result["log"] += "\n流弹擦过掩体，猎人 HP -%d。" % hunter_hit
		result["target"] = "hunter"

	# Check failure
	if not player.is_alive() or not vehicle.is_operational():
		is_running = false
		result["status"] = "failed"
		battle_failed.emit()
		return result

	return result


func finish_early(victory: bool) -> void:
	is_running = false
	if victory:
		battle_victory.emit(str(current_route["name"]))
	else:
		battle_failed.emit()


func get_current_wave() -> int:
	return enemy.wave if enemy else 1


func get_battle_time() -> float:
	return battle_time


func get_enemy_hp() -> Dictionary:
	if enemy:
		return {"current": enemy.hp, "maximum": enemy.max_hp}
	return {"current": 0, "maximum": 0}
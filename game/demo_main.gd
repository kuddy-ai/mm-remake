# DemoMain - thin orchestrator for the game prototype
# Only handles initialization, state machine, and music
# All detailed logic is in systems, states, and visual layers

extends Node


# === Dependencies ===

const AssetRegistry := preload("res://game/visual/asset_registry.gd")

# Legacy constant for path check script compatibility
const MUSIC_OPENING := "res://assets/audio/bgm/001_opening_theme.ogg"
const RouteData := preload("res://game/data/route_data.gd")
const PlayerData := preload("res://game/data/player_data.gd")
const VehicleData := preload("res://game/data/vehicle_data.gd")
const BattleSystem := preload("res://game/systems/battle_system.gd")
const ResourceSystem := preload("res://game/systems/resource_system.gd")
const UpgradeSystem := preload("res://game/systems/upgrade_system.gd")

const MenuState := preload("res://game/states/menu_state.gd")
const TownState := preload("res://game/states/town_state.gd")
const RouteState := preload("res://game/states/route_state.gd")
const BattleState := preload("res://game/states/battle_state.gd")
const GarageState := preload("res://game/states/garage_state.gd")
const ResultState := preload("res://game/states/result_state.gd")


# === State Constants ===

const STATE_MENU := "menu"
const STATE_TOWN := "town"
const STATE_ROUTE := "route"
const STATE_BATTLE := "battle"
const STATE_GARAGE := "garage"
const STATE_RESULT := "result"


# === Core Systems ===

var player: PlayerData
var vehicle: VehicleData
var battle: BattleSystem
var resources: ResourceSystem
var upgrades: UpgradeSystem


# === State Machine ===

var current_state: GameState
var states: Dictionary = {}


# === UI Structure ===

var root: Control
var scene_layer: Control
var ui_layer: CanvasLayer


# === Music ===

var music_player: AudioStreamPlayer


# === Route Selection ===

var selected_route: Dictionary = {}
var route_index: int = 0


# === Result Data ===

var result_text: String = ""
var result_scrap: int = 0
var result_xp: int = 0


func _ready() -> void:
	get_window().title = "横板像素废土放置 RPG"
	get_viewport().canvas_item_default_texture_filter = Viewport.DEFAULT_CANVAS_ITEM_TEXTURE_FILTER_NEAREST

	_init_systems()
	_init_states()
	_init_music()
	_build_root()
	_switch_state(STATE_MENU)


func _process(delta: float) -> void:
	if current_state and current_state.is_active:
		current_state.update(delta)


func _init_systems() -> void:
	# Create data objects
	player = PlayerData.new()
	vehicle = VehicleData.new()

	# Create systems
	resources = ResourceSystem.new()
	battle = BattleSystem.new()
	upgrades = UpgradeSystem.new()

	# Setup dependencies
	battle.setup(player, vehicle)
	upgrades.setup(resources, player, vehicle)


func _init_states() -> void:
	states[STATE_MENU] = MenuState.new()
	states[STATE_TOWN] = TownState.new()
	states[STATE_ROUTE] = RouteState.new()
	states[STATE_BATTLE] = BattleState.new()
	states[STATE_GARAGE] = GarageState.new()
	states[STATE_RESULT] = ResultState.new()

	# Connect state signals
	for state_name_key in states:
		var state: GameState = states[state_name_key]
		state.transition_requested.connect(_on_state_transition_requested)
		state.state_completed.connect(_on_state_completed)


func _init_music() -> void:
	music_player = AudioStreamPlayer.new()
	music_player.name = "OpeningMusic"
	music_player.volume_db = -10.0
	add_child(music_player)

	var stream := AssetRegistry.load_bgm(AssetRegistry.BGM_OPENING)
	if stream:
		music_player.stream = stream
		music_player.play()


func _build_root() -> void:
	root = Control.new()
	root.name = "GameRoot"
	root.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(root)

	scene_layer = Control.new()
	scene_layer.name = "SideViewScene"
	scene_layer.set_anchors_preset(Control.PRESET_FULL_RECT)
	root.add_child(scene_layer)

	ui_layer = CanvasLayer.new()
	ui_layer.name = "HudCanvasLayer"
	ui_layer.layer = 10
	root.add_child(ui_layer)


func _switch_state(next_state: String) -> void:
	# Exit current state
	if current_state:
		current_state.exit()

	# Clear layers
	_clear(scene_layer)
	_clear(ui_layer)

	# Build context for new state
	var context := _build_context()

	# Enter new state
	current_state = states.get(next_state, states[STATE_MENU])
	current_state.enter(context)


func _build_context() -> Dictionary:
	return {
		"scene_layer": scene_layer,
		"ui_layer": ui_layer,
		"player": player,
		"vehicle": vehicle,
		"resources": resources,
		"battle_system": battle,
		"selected_route": selected_route,
		"result_text": result_text,
		"result_scrap": result_scrap,
		"result_xp": result_xp,
		"current_scrap": resources.scrap,
		"current_fuel": resources.fuel,
		"current_rations": resources.rations,
	}


func _on_state_transition_requested(next_state: String) -> void:
	_switch_state(next_state)


func _on_state_completed(result: Dictionary) -> void:
	var action: String = result.get("action", "")

	if action == "start_route":
		_handle_start_route(result)
	elif action == "battle_result":
		_handle_battle_result(result)
	elif action == "upgrade_tank":
		_handle_upgrade_tank()
	elif action == "upgrade_cannon":
		_handle_upgrade_cannon()
	elif action == "upgrade_hunter":
		_handle_upgrade_hunter()
	elif action == "buy_fuel":
		_handle_buy_fuel()


func _handle_start_route(result: Dictionary) -> void:
	route_index = result.get("route_index", 0)
	selected_route = RouteData.get_route(route_index)

	# Check fuel
	if not RouteData.can_afford_route(route_index, resources.fuel):
		result_text = "燃料不足，远征取消。"
		result_scrap = 0
		result_xp = 0
		_switch_state(STATE_RESULT)
		return

	# Spend fuel and start battle
	resources.spend_fuel(int(selected_route["fuel"]))
	_switch_state(STATE_BATTLE)


func _handle_battle_result(result: Dictionary) -> void:
	var victory: bool = result.get("victory", false)

	if victory:
		var rewards := resources.grant_victory_rewards(selected_route, vehicle.get_bonus_scrap())
		result_scrap = rewards["scrap"]
		result_xp = rewards["xp"]

		# Check for level up
		player.add_xp(result_xp)

		result_text = "远征成功：%s 已清理。" % str(selected_route["name"])
	else:
		var rewards := resources.grant_failure_rewards(selected_route)
		result_scrap = rewards["scrap"]
		result_xp = rewards["xp"]

		player.full_heal()
		vehicle.recover_from_failure()

		result_text = "远征中止：队伍带着残骸返回锈镇。"

	_switch_state(STATE_RESULT)


func _handle_upgrade_tank() -> void:
	if upgrades.upgrade_tank():
		pass  # Success
	_switch_state(STATE_GARAGE)


func _handle_upgrade_cannon() -> void:
	if upgrades.upgrade_cannon():
		pass  # Success
	_switch_state(STATE_GARAGE)


func _handle_upgrade_hunter() -> void:
	if upgrades.upgrade_hunter():
		pass  # Success
	_switch_state(STATE_GARAGE)


func _handle_buy_fuel() -> void:
	if upgrades.buy_fuel():
		pass  # Success
	_switch_state(STATE_GARAGE)


func _clear(node: Node) -> void:
	for child in node.get_children():
		child.queue_free()
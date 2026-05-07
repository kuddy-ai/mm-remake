# Battle state - auto-battle execution
# Handles the automatic combat flow

class_name BattleState

extends GameState


# === Dependencies ===

const HUDBuilder := preload("res://game/ui/hud_builder.gd")
const UIStyleGuide := preload("res://game/ui_style_guide.gd")
const WastelandScene := preload("res://game/visual/wasteland_scene.gd")
const RouteData := preload("res://game/data/route_data.gd")
const BattleSystem := preload("res://game/systems/battle_system.gd")


var state_name: String = "battle"


# === Systems ===

var battle: BattleSystem


# === UI References ===

var ui_layer: CanvasLayer
var battle_log: Label
var battle_status: Label
var hunter_hp_bar: Control
var tank_hp_bar: Control
var enemy_hp_bar: Control


# === State ===

var selected_route: Dictionary = {}


func enter(context: Dictionary) -> void:
	is_active = true
	ui_layer = context.get("ui_layer", null)
	battle = context.get("battle_system", null)
	selected_route = context.get("selected_route", {})

	if ui_layer == null or battle == null:
		return

	# Setup battle system signals
	battle.wave_changed.connect(_on_wave_changed)
	battle.enemy_hp_changed.connect(_on_enemy_hp_changed)
	battle.battle_victory.connect(_on_battle_victory)
	battle.battle_failed.connect(_on_battle_failed)

	# Add background scene
	var scene := WastelandScene.new("battle")
	scene.set_anchors_preset(Control.PRESET_FULL_RECT)
	context.scene_layer.add_child(scene)

	# Build game frame
	_build_game_frame(context)

	# Right info panel
	_add_right_panel("战斗信息", [
		"模式：自动普攻 / 主炮冷却触发",
		"路线威胁：%d" % int(selected_route["threat"]),
		"敌方波次：%d" % int(selected_route["waves"]),
	])

	# Battle status panel
	var panel := HUDBuilder.make_panel(Vector2(360, 178))
	panel.set_anchors_preset(Control.PRESET_TOP_LEFT)
	panel.offset_left = 24
	panel.offset_top = 104
	panel.offset_right = 384
	panel.offset_bottom = 282
	ui_layer.add_child(panel)

	var col := VBoxContainer.new()
	col.add_theme_constant_override("separation", 10)
	panel.add_child(col)

	battle_status = HUDBuilder.make_label("", 16, UIStyleGuide.GOLD)
	col.add_child(battle_status)

	var player := context.get("player", null)
	var vehicle := context.get("vehicle", null)

	hunter_hp_bar = HUDBuilder.make_progress("猎人", player.hp if player else 100, 100, UIStyleGuide.HP, "hp")
	col.add_child(hunter_hp_bar)

	tank_hp_bar = HUDBuilder.make_progress("战车", vehicle.armor if vehicle else 120, vehicle.max_armor if vehicle else 120, UIStyleGuide.ARMOR, "tank")
	col.add_child(tank_hp_bar)

	enemy_hp_bar = HUDBuilder.make_progress("敌方", 0, 100, UIStyleGuide.DANGER, "enemy")
	col.add_child(enemy_hp_bar)

	# Battle log panel
	var log_panel := HUDBuilder.make_panel(Vector2(460, 116))
	log_panel.set_anchors_preset(Control.PRESET_BOTTOM_LEFT)
	log_panel.offset_left = 24
	log_panel.offset_top = -212
	log_panel.offset_right = 484
	log_panel.offset_bottom = -96
	ui_layer.add_child(log_panel)

	battle_log = HUDBuilder.make_label("引擎低吼，战车驶入交战区。", 15, UIStyleGuide.TEXT)
	battle_log.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	log_panel.add_child(battle_log)

	# Bottom bar
	_add_bottom_bar([
		{"text": "加速结算", "call": _on_finish_battle.bind(true)},
		{"text": "撤退", "call": _on_finish_battle.bind(false)},
	])

	# Start battle
	battle.start_battle(selected_route)
	_refresh_battle_ui()


func exit() -> void:
	is_active = false
	if battle:
		battle.wave_changed.disconnect(_on_wave_changed)
		battle.enemy_hp_changed.disconnect(_on_enemy_hp_changed)
		battle.battle_victory.disconnect(_on_battle_victory)
		battle.battle_failed.disconnect(_on_battle_failed)


func update(delta: float) -> void:
	if not is_active or battle == null:
		return

	var result := battle.update(delta)

	if result.has("log"):
		battle_log.text = result["log"]

	_refresh_battle_ui()


func _build_game_frame(context: Dictionary) -> void:
	var vehicle := context.get("vehicle", null)
	var player := context.get("player", null)
	var resources := context.get("resources", null)

	var top := HUDBuilder.make_panel(Vector2(0, 72))
	top.set_anchors_preset(Control.PRESET_TOP_WIDE)
	top.offset_left = 12
	top.offset_top = 10
	top.offset_right = -12
	top.offset_bottom = 82
	ui_layer.add_child(top)

	var root_row := HBoxContainer.new()
	root_row.add_theme_constant_override("separation", 8)
	top.add_child(root_row)

	# Title
	var title_col := VBoxContainer.new()
	title_col.custom_minimum_size = Vector2(160, 50)
	title_col.add_theme_constant_override("separation", 2)
	root_row.add_child(title_col)
	title_col.add_child(HUDBuilder.make_label(str(selected_route["name"]), UIStyleGuide.FONT_SECTION, UIStyleGuide.GOLD))
	title_col.add_child(HUDBuilder.make_label("自动战斗中", UIStyleGuide.FONT_TINY, UIStyleGuide.TEXT_MUTED))

	# Hunter HP
	var bars := VBoxContainer.new()
	bars.custom_minimum_size = Vector2(226, 54)
	bars.add_theme_constant_override("separation", 2)
	root_row.add_child(bars)
	bars.add_child(HUDBuilder.make_progress("HP", player.hp if player else 100, 100, UIStyleGuide.HP, "hp"))
	bars.add_child(HUDBuilder.make_progress("体力", 68, 100, UIStyleGuide.STAMINA, "energy"))

	# Vehicle status
	var tank_bars := VBoxContainer.new()
	tank_bars.custom_minimum_size = Vector2(226, 54)
	tank_bars.add_theme_constant_override("separation", 2)
	root_row.add_child(tank_bars)
	tank_bars.add_child(HUDBuilder.make_progress("战车", vehicle.armor if vehicle else 120, vehicle.max_armor if vehicle else 120, UIStyleGuide.ARMOR, "tank"))
	tank_bars.add_child(HUDBuilder.make_progress("能量", 42 + (vehicle.cannon_level if vehicle else 1) * 8, 100, UIStyleGuide.ENERGY, "energy"))

	# Resources
	var resource_col := VBoxContainer.new()
	resource_col.custom_minimum_size = Vector2(180, 54)
	resource_col.add_theme_constant_override("separation", 3)
	root_row.add_child(resource_col)

	var res_row_a := HBoxContainer.new()
	res_row_a.add_theme_constant_override("separation", 6)
	resource_col.add_child(res_row_a)
	res_row_a.add_child(HUDBuilder.make_icon("coin", "%d" % (resources.scrap if resources else 120)))
	res_row_a.add_child(HUDBuilder.make_icon("fuel", "%d" % (resources.fuel if resources else 48)))


func _add_right_panel(title: String, lines: Array) -> void:
	var panel := HUDBuilder.make_panel(Vector2(286, 0))
	panel.set_anchors_preset(Control.PRESET_RIGHT_WIDE)
	panel.offset_left = -306
	panel.offset_top = 96
	panel.offset_right = -14
	panel.offset_bottom = -90
	ui_layer.add_child(panel)

	var col := VBoxContainer.new()
	col.add_theme_constant_override("separation", 12)
	panel.add_child(col)
	col.add_child(HUDBuilder.make_label(title, 18, UIStyleGuide.GOLD))

	for line in lines:
		var label := HUDBuilder.make_label(str(line), 13, UIStyleGuide.TEXT)
		label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		col.add_child(label)


func _add_bottom_bar(buttons: Array) -> void:
	var bar := HUDBuilder.make_panel(Vector2(0, 66))
	bar.set_anchors_preset(Control.PRESET_BOTTOM_WIDE)
	bar.offset_left = 12
	bar.offset_top = -74
	bar.offset_right = -12
	bar.offset_bottom = -10
	ui_layer.add_child(bar)

	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 10)
	bar.add_child(row)

	for item in buttons:
		var callback: Callable = item["call"]
		row.add_child(HUDBuilder.make_button(str(item["text"]), callback, Vector2(166, 46), 15))


func _refresh_battle_ui() -> void:
	if battle_status != null:
		battle_status.text = "第 %d/%d 波  ·  战斗 %.1fs" % [battle.get_current_wave(), int(selected_route["waves"]), battle.get_battle_time()]

	var enemy_hp := battle.get_enemy_hp()
	if enemy_hp_bar != null and enemy_hp.has("current"):
		if enemy_hp_bar.has_method("set_values"):
			enemy_hp_bar.call("set_values", enemy_hp["current"], enemy_hp["maximum"])


func _on_wave_changed(wave: int, total: int) -> void:
	pass  # UI updated via _refresh_battle_ui


func _on_enemy_hp_changed(current: int, maximum: int) -> void:
	if enemy_hp_bar != null and enemy_hp_bar.has_method("set_values"):
		enemy_hp_bar.call("set_values", current, maximum)


func _on_battle_victory(route_name: String) -> void:
	complete_with_result({"action": "battle_result", "victory": true, "route": selected_route})


func _on_battle_failed() -> void:
	complete_with_result({"action": "battle_result", "victory": false, "route": selected_route})


func _on_finish_battle(victory: bool) -> void:
	battle.finish_early(victory)
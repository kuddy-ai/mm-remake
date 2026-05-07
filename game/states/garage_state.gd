# Garage state - upgrade interface
# Player upgrades tank, cannon, hunter, and buys fuel

class_name GarageState

extends GameState


# === Dependencies ===

const HUDBuilder := preload("res://game/ui/hud_builder.gd")
const UIStyleGuide := preload("res://game/ui_style_guide.gd")
const WastelandScene := preload("res://game/visual/wasteland_scene.gd")
const ResourceSystem := preload("res://game/systems/resource_system.gd")


var state_name: String = "garage"


# === Systems ===

var resources: ResourceSystem


# === UI References ===

var ui_layer: CanvasLayer


func enter(context: Dictionary) -> void:
	is_active = true
	ui_layer = context.get("ui_layer", null)
	resources = context.get("resources", null)

	if ui_layer == null:
		return

	# Add background scene
	var scene := WastelandScene.new("town")
	scene.set_anchors_preset(Control.PRESET_FULL_RECT)
	context.scene_layer.add_child(scene)

	# Build game frame
	_build_game_frame(context)

	# Right panel - current stats
	var player := context.get("player", null)
	var vehicle := context.get("vehicle", null)

	_add_right_panel("当前战力", [
		"猎人 Lv.%d / HP %d" % [player.level if player else 1, player.hp if player else 100],
		"战车 Lv.%d / 装甲 %d/%d" % [vehicle.tank_level if vehicle else 1, vehicle.armor if vehicle else 120, vehicle.max_armor if vehicle else 120],
		"主炮 Lv.%d" % [vehicle.cannon_level if vehicle else 1],
		"废金属：%d" % [resources.scrap if resources else 120],
	])

	# Upgrade panel
	var panel := HUDBuilder.make_panel(Vector2(500, 280))
	panel.set_anchors_preset(Control.PRESET_TOP_LEFT)
	panel.offset_left = 26
	panel.offset_top = 86
	panel.offset_right = 526
	panel.offset_bottom = 366
	ui_layer.add_child(panel)

	var col := VBoxContainer.new()
	col.add_theme_constant_override("separation", 12)
	panel.add_child(col)
	col.add_child(HUDBuilder.make_label("升级项目", 24, UIStyleGuide.GOLD))

	# Upgrade buttons
	col.add_child(HUDBuilder.make_button("强化战车装甲  费用 %d" % ResourceSystem.UPGRADE_COST_TANK, _on_upgrade_tank, Vector2(450, 48), 16))
	col.add_child(HUDBuilder.make_button("校准主炮火控  费用 %d" % ResourceSystem.UPGRADE_COST_CANNON, _on_upgrade_cannon, Vector2(450, 48), 16))
	col.add_child(HUDBuilder.make_button("训练猎人等级  费用 %d" % ResourceSystem.UPGRADE_COST_HUNTER, _on_upgrade_hunter, Vector2(450, 48), 16))
	col.add_child(HUDBuilder.make_button("补给燃料 +%d  费用 %d" % [ResourceSystem.BUY_FUEL_AMOUNT, ResourceSystem.BUY_FUEL_COST], _on_buy_fuel, Vector2(450, 48), 16))

	# Bottom bar
	_add_bottom_bar([
		{"text": "返回城镇", "call": _on_town_pressed},
		{"text": "路线地图", "call": _on_route_pressed},
	])


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
	title_col.add_child(HUDBuilder.make_label("车库升级", UIStyleGuide.FONT_SECTION, UIStyleGuide.GOLD))
	title_col.add_child(HUDBuilder.make_label("消耗废金属强化角色与战车", UIStyleGuide.FONT_TINY, UIStyleGuide.TEXT_MUTED))

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

	for slot_name in ["cannon", "med", "mine", "repair", "radio"]:
		row.add_child(HUDBuilder.make_inventory_slot(slot_name))


func _on_upgrade_tank() -> void:
	complete_with_result({"action": "upgrade_tank"})


func _on_upgrade_cannon() -> void:
	complete_with_result({"action": "upgrade_cannon"})


func _on_upgrade_hunter() -> void:
	complete_with_result({"action": "upgrade_hunter"})


func _on_buy_fuel() -> void:
	complete_with_result({"action": "buy_fuel"})


func _on_town_pressed() -> void:
	request_transition("town")


func _on_route_pressed() -> void:
	request_transition("route")
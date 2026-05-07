# Town state - settlement hub
# Central hub for navigation

class_name TownState

extends GameState


# === Dependencies ===

const HUDBuilder := preload("res://game/ui/hud_builder.gd")
const UIStyleGuide := preload("res://game/ui_style_guide.gd")
const WastelandScene := preload("res://game/visual/wasteland_scene.gd")


var state_name: String = "town"


# === UI References ===

var ui_layer: CanvasLayer


func enter(context: Dictionary) -> void:
	is_active = true
	ui_layer = context.get("ui_layer", null)

	if ui_layer == null:
		return

	# Add background scene
	var scene := WastelandScene.new("town")
	scene.set_anchors_preset(Control.PRESET_FULL_RECT)
	context.scene_layer.add_child(scene)

	# Build game frame (HUD top bar)
	_build_game_frame(context)

	# Right info panel
	_add_right_panel("城镇情报", [
		"解锁区域：3",
		"可挑战路线：废弃加油站 / 干涸河床 / 雷达废墟",
		"当前循环：选择路线后自动战斗，胜利结算资源。",
	])

	# Town description panel
	var town_panel := HUDBuilder.make_panel(Vector2(430, 150))
	town_panel.set_anchors_preset(Control.PRESET_BOTTOM_LEFT)
	town_panel.offset_left = 22
	town_panel.offset_top = -236
	town_panel.offset_right = 452
	town_panel.offset_bottom = -86
	ui_layer.add_child(town_panel)

	var copy := HUDBuilder.make_label("马库斯修理站\n战车还能跑，但每次远征都要消耗燃料。先打低威胁路线攒废金属，再升级装甲和主炮。", 16, UIStyleGuide.TEXT)
	copy.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	town_panel.add_child(copy)

	# Bottom bar
	_add_bottom_bar([
		{"text": "路线地图", "call": _on_route_pressed},
		{"text": "车库升级", "call": _on_garage_pressed},
		{"text": "开始推荐路线", "call": _on_start_route.bind(0)},
		{"text": "主菜单", "call": _on_menu_pressed},
	])


func _build_game_frame(context: Dictionary) -> void:
	var player := context.get("player", null)
	var vehicle := context.get("vehicle", null)
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

	# Title section
	var title_col := VBoxContainer.new()
	title_col.custom_minimum_size = Vector2(160, 50)
	title_col.add_theme_constant_override("separation", 2)
	root_row.add_child(title_col)
	title_col.add_child(HUDBuilder.make_label("锈镇 Hub", UIStyleGuide.FONT_SECTION, UIStyleGuide.GOLD))
	title_col.add_child(HUDBuilder.make_label("整备、升级、选择路线", UIStyleGuide.FONT_TINY, UIStyleGuide.TEXT_MUTED))

	# Hunter status
	var bars := VBoxContainer.new()
	bars.custom_minimum_size = Vector2(226, 54)
	bars.add_theme_constant_override("separation", 2)
	root_row.add_child(bars)

	var hp := player.hp if player else 100
	bars.add_child(HUDBuilder.make_progress("HP", hp, 100, UIStyleGuide.HP, "hp"))
	bars.add_child(HUDBuilder.make_progress("体力", 68, 100, UIStyleGuide.STAMINA, "energy"))

	# Vehicle status
	var tank_bars := VBoxContainer.new()
	tank_bars.custom_minimum_size = Vector2(226, 54)
	tank_bars.add_theme_constant_override("separation", 2)
	root_row.add_child(tank_bars)

	var armor := vehicle.armor if vehicle else 120
	var max_armor := vehicle.max_armor if vehicle else 120
	var cannon := vehicle.cannon_level if vehicle else 1

	tank_bars.add_child(HUDBuilder.make_progress("战车", armor, max_armor, UIStyleGuide.ARMOR, "tank"))
	tank_bars.add_child(HUDBuilder.make_progress("能量", 42 + cannon * 8, 100, UIStyleGuide.ENERGY, "energy"))

	# Weapon slot
	root_row.add_child(_make_weapon_slot("主炮 Mk.%d" % cannon))

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

	var res_row_b := HBoxContainer.new()
	res_row_b.add_theme_constant_override("separation", 6)
	resource_col.add_child(res_row_b)
	res_row_b.add_child(HUDBuilder.make_icon("ammo", "AUTO"))
	res_row_b.add_child(HUDBuilder.make_icon("scrap", "Lv.%d" % (vehicle.tank_level if vehicle else 1)))

	# Status icons
	root_row.add_child(_make_status_icons())


func _make_weapon_slot(name: String) -> PanelContainer:
	var slot := HUDBuilder.make_panel(Vector2(150, 66))
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 8)
	slot.add_child(row)

	var icon := HUDBuilder.PixelIcon.new("weapon", "")
	icon.custom_minimum_size = UIStyleGuide.ICON_COMPACT_SIZE
	row.add_child(icon)

	var col := VBoxContainer.new()
	col.add_theme_constant_override("separation", 2)
	row.add_child(col)
	col.add_child(HUDBuilder.make_label("当前武器", UIStyleGuide.FONT_TINY, UIStyleGuide.TEXT_MUTED))
	col.add_child(HUDBuilder.make_label(name, UIStyleGuide.FONT_BODY, UIStyleGuide.GOLD))
	col.add_child(HUDBuilder.make_label("弹药 AUTO", UIStyleGuide.FONT_SMALL, UIStyleGuide.TEXT))

	return slot


func _make_status_icons() -> PanelContainer:
	var panel := HUDBuilder.make_panel(Vector2(132, 66))
	var col := VBoxContainer.new()
	col.add_theme_constant_override("separation", 4)
	panel.add_child(col)
	col.add_child(HUDBuilder.make_label("状态", UIStyleGuide.FONT_TINY, UIStyleGuide.TEXT_MUTED))

	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 5)
	col.add_child(row)

	for kind in ["fuel", "ammo", "repair"]:
		var icon := HUDBuilder.PixelIcon.new(kind, "")
		icon.custom_minimum_size = Vector2(32, 28)
		row.add_child(icon)

	return panel


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

	var spacer := Control.new()
	spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(spacer)
	row.add_child(HUDBuilder.make_label("核心循环：城镇 Hub → 路线 → 自动战斗 → 资源 → 升级 → 新区域", UIStyleGuide.FONT_BODY, UIStyleGuide.TEXT_MUTED))


func _on_route_pressed() -> void:
	request_transition("route")


func _on_garage_pressed() -> void:
	request_transition("garage")


func _on_start_route(index: int) -> void:
	complete_with_result({"action": "start_route", "route_index": index})


func _on_menu_pressed() -> void:
	request_transition("menu")
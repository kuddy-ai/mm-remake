# Route state - route selection screen
# Player chooses which route to attempt

class_name RouteState

extends GameState


# === Dependencies ===

const HUDBuilder := preload("res://game/ui/hud_builder.gd")
const UIStyleGuide := preload("res://game/ui_style_guide.gd")
const WastelandScene := preload("res://game/visual/wasteland_scene.gd")
const RouteData := preload("res://game/data/route_data.gd")


var state_name: String = "route"


# === UI References ===

var ui_layer: CanvasLayer


func enter(context: Dictionary) -> void:
	is_active = true
	ui_layer = context.get("ui_layer", null)

	if ui_layer == null:
		return

	# Add background scene
	var scene := WastelandScene.new("route")
	scene.set_anchors_preset(Control.PRESET_FULL_RECT)
	context.scene_layer.add_child(scene)

	# Build game frame
	_build_game_frame(context)

	# Right info panel
	_add_right_panel("路线规则", [
		"路线消耗燃料并产出废金属与经验。",
		"威胁越高，敌人血量和波次越高。",
		"胜利后进入结算界面；失败会带着少量残骸返回城镇。",
	])

	# Route list
	var routes := RouteData.ROUTES
	var list := VBoxContainer.new()
	list.set_anchors_preset(Control.PRESET_LEFT_WIDE)
	list.offset_left = 26
	list.offset_top = 84
	list.offset_right = 430
	list.offset_bottom = -92
	list.add_theme_constant_override("separation", 10)
	ui_layer.add_child(list)

	var resources := context.get("resources", null)

	for i in range(routes.size()):
		var r: Dictionary = routes[i]
		var callback := _on_route_selected.bind(i)
		var btn := HUDBuilder.make_button(RouteData.get_route_display_text(i), callback, Vector2(400, 52), 15)

		# Check fuel availability
		if resources and not RouteData.can_afford_route(i, resources.fuel):
			btn.disabled = true
			btn.text += " (燃料不足)"

		list.add_child(btn)

	# Bottom bar
	_add_bottom_bar([
		{"text": "返回城镇", "call": _on_town_pressed},
		{"text": "车库升级", "call": _on_garage_pressed},
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
	title_col.add_child(HUDBuilder.make_label("路线地图", UIStyleGuide.FONT_SECTION, UIStyleGuide.GOLD))
	title_col.add_child(HUDBuilder.make_label("选择路线 → 自动战斗", UIStyleGuide.FONT_TINY, UIStyleGuide.TEXT_MUTED))

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

	var res_row_b := HBoxContainer.new()
	res_row_b.add_theme_constant_override("separation", 6)
	resource_col.add_child(res_row_b)
	res_row_b.add_child(HUDBuilder.make_icon("ammo", "AUTO"))
	res_row_b.add_child(HUDBuilder.make_icon("scrap", "Lv.%d" % (vehicle.tank_level if vehicle else 1)))


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


func _on_route_selected(index: int) -> void:
	complete_with_result({"action": "start_route", "route_index": index})


func _on_town_pressed() -> void:
	request_transition("town")


func _on_garage_pressed() -> void:
	request_transition("garage")
# Result state - battle settlement screen
# Shows rewards and provides navigation options

class_name ResultState

extends GameState


# === Dependencies ===

const HUDBuilder := preload("res://game/ui/hud_builder.gd")
const UIStyleGuide := preload("res://game/ui_style_guide.gd")
const WastelandScene := preload("res://game/visual/wasteland_scene.gd")


var state_name: String = "result"


# === UI References ===

var ui_layer: CanvasLayer


# === State ===

var result_text: String = ""
var result_scrap: int = 0
var result_xp: int = 0
var current_scrap: int = 0
var current_fuel: int = 0
var current_rations: int = 0


func enter(context: Dictionary) -> void:
	is_active = true
	ui_layer = context.get("ui_layer", null)

	result_text = context.get("result_text", "远征完成。")
	result_scrap = context.get("result_scrap", 0)
	result_xp = context.get("result_xp", 0)
	current_scrap = context.get("current_scrap", 0)
	current_fuel = context.get("current_fuel", 0)
	current_rations = context.get("current_rations", 0)

	if ui_layer == null:
		return

	# Add background scene
	var scene := WastelandScene.new("route")
	scene.set_anchors_preset(Control.PRESET_FULL_RECT)
	context.scene_layer.add_child(scene)

	# Build game frame
	_build_game_frame(context)

	# Result panel
	var panel := HUDBuilder.make_panel(Vector2(620, 360))
	panel.set_anchors_preset(Control.PRESET_CENTER)
	panel.offset_left = -310
	panel.offset_top = -180
	panel.offset_right = 310
	panel.offset_bottom = 180
	ui_layer.add_child(panel)

	var col := VBoxContainer.new()
	col.add_theme_constant_override("separation", 14)
	panel.add_child(col)

	col.add_child(HUDBuilder.make_label(result_text, 26, UIStyleGuide.GOLD))
	col.add_child(HUDBuilder.make_label("获得废金属 +%d\n获得经验 +%d\n当前资源：废金属 %d / 燃料 %d / 口粮 %d" % [result_scrap, result_xp, current_scrap, current_fuel, current_rations], 18, UIStyleGuide.TEXT))
	col.add_child(HUDBuilder.make_label("下一步建议：装甲不足先回车库；燃料充足可以继续选择新路线。", 15, UIStyleGuide.CYAN))

	col.add_child(HUDBuilder.make_button("回到城镇 Hub", _on_town_pressed, Vector2(260, 48), 17))
	col.add_child(HUDBuilder.make_button("打开车库升级", _on_garage_pressed, Vector2(260, 48), 17))
	col.add_child(HUDBuilder.make_button("继续选择路线", _on_route_pressed, Vector2(260, 48), 17))


func _build_game_frame(context: Dictionary) -> void:
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
	title_col.add_child(HUDBuilder.make_label("结算界面", UIStyleGuide.FONT_SECTION, UIStyleGuide.GOLD))
	title_col.add_child(HUDBuilder.make_label("资源入库 → 升级或继续远征", UIStyleGuide.FONT_TINY, UIStyleGuide.TEXT_MUTED))


func _on_town_pressed() -> void:
	request_transition("town")


func _on_garage_pressed() -> void:
	request_transition("garage")


func _on_route_pressed() -> void:
	request_transition("route")
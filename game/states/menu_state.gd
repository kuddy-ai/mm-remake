# Menu state - main menu screen
# Entry point for the game

class_name MenuState

extends GameState


# === Dependencies ===

const HUDBuilder := preload("res://game/ui/hud_builder.gd")
const UIStyleGuide := preload("res://game/ui_style_guide.gd")
const AssetRegistry := preload("res://game/visual/asset_registry.gd")
const WastelandScene := preload("res://game/visual/wasteland_scene.gd")


var state_name: String = "menu"


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

	# Add shade overlay
	ui_layer.add_child(HUDBuilder.make_shade_rect(0.48))

	# Title
	var title := HUDBuilder.make_label("荒原战车：放置远征", 62, UIStyleGuide.GOLD)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.set_anchors_preset(Control.PRESET_CENTER)
	title.offset_left = -430
	title.offset_top = -190
	title.offset_right = 430
	title.offset_bottom = -110
	ui_layer.add_child(title)

	# Subtitle
	var subtitle := HUDBuilder.make_label("横板像素废土放置 RPG", 22, UIStyleGuide.CYAN)
	subtitle.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	subtitle.set_anchors_preset(Control.PRESET_CENTER)
	subtitle.offset_left = -280
	subtitle.offset_top = -104
	subtitle.offset_right = 280
	subtitle.offset_bottom = -64
	ui_layer.add_child(subtitle)

	# Menu buttons
	var menu := VBoxContainer.new()
	menu.set_anchors_preset(Control.PRESET_CENTER)
	menu.offset_left = -150
	menu.offset_top = -28
	menu.offset_right = 150
	menu.offset_bottom = 160
	menu.add_theme_constant_override("separation", 10)
	ui_layer.add_child(menu)

	menu.add_child(HUDBuilder.make_button("进入城镇 Hub", _on_town_pressed, Vector2(300, 48), 18))
	menu.add_child(HUDBuilder.make_button("路线地图", _on_route_pressed, Vector2(300, 48), 18))
	menu.add_child(HUDBuilder.make_button("车库升级", _on_garage_pressed, Vector2(300, 48), 18))

	# Version info
	var version := HUDBuilder.make_label("v2 prototype · 城镇 → 路线 → 自动战斗 → 资源 → 升级 → 新区域", UIStyleGuide.FONT_BODY, UIStyleGuide.TEXT_MUTED)
	version.set_anchors_preset(Control.PRESET_BOTTOM_LEFT)
	version.offset_left = 20
	version.offset_top = -34
	version.offset_right = 620
	version.offset_bottom = -12
	ui_layer.add_child(version)


func _on_town_pressed() -> void:
	request_transition("town")


func _on_route_pressed() -> void:
	request_transition("route")


func _on_garage_pressed() -> void:
	request_transition("garage")
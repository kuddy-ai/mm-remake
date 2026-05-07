# HUD Builder - shared UI construction utilities
# Provides common UI element creation methods

class_name HUDBuilder

extends RefCounted


# === Dependencies ===

const UIStyleGuide := preload("res://game/ui_style_guide.gd")
const AssetRegistry := preload("res://game/visual/asset_registry.gd")


# === Preloaded Scenes ===

static var _panel_scene: PackedScene = null
static var _button_scene: PackedScene = null
static var _progress_scene: PackedScene = null


static func _ensure_loaded() -> void:
	if _panel_scene == null:
		_panel_scene = AssetRegistry.load_scene(AssetRegistry.UI_PANEL_METAL)
	if _button_scene == null:
		_button_scene = AssetRegistry.load_scene(AssetRegistry.UI_BUTTON_WASTELAND)
	if _progress_scene == null:
		_progress_scene = AssetRegistry.load_scene(AssetRegistry.UI_PROGRESS_BAR)


# === Factory Methods ===

static func make_panel(min_size: Vector2) -> PanelContainer:
	_ensure_loaded()
	var panel := _panel_scene.instantiate() as PanelContainer
	panel.custom_minimum_size = min_size
	panel.theme = load(AssetRegistry.THEME_WASTELAND)
	return panel


static func make_button(text: String, callback: Callable, min_size: Vector2 = Vector2(160, 46), font_size: int = 14) -> Button:
	_ensure_loaded()
	var button := _button_scene.instantiate() as Button
	button.text = text
	button.custom_minimum_size = min_size
	button.focus_mode = Control.FOCUS_NONE
	button.theme = load(AssetRegistry.THEME_WASTELAND)

	var system_font := SystemFont.new()
	system_font.font_names = PackedStringArray(["Noto Sans CJK SC", "WenQuanYi Zen Hei", "Noto Sans", "Sans"])
	button.add_theme_font_override("font", system_font)
	button.add_theme_font_size_override("font_size", font_size)
	button.add_theme_color_override("font_color", UIStyleGuide.TEXT)
	button.add_theme_color_override("font_hover_color", UIStyleGuide.TEXT.lightened(0.08))
	button.add_theme_color_override("font_pressed_color", UIStyleGuide.GOLD)

	button.pressed.connect(callback)
	return button


static func make_progress(label: String, current: int, maximum: int, color: Color, icon: String) -> Control:
	_ensure_loaded()
	var bar := _progress_scene.instantiate() as Control
	bar.custom_minimum_size = UIStyleGuide.METER_SIZE
	if bar.has_method("configure"):
		bar.call("configure", label, current, maximum, color, icon)
	return bar


static func make_label(text: String, font_size: int, color: Color) -> Label:
	var label := Label.new()
	label.text = text

	var system_font := SystemFont.new()
	system_font.font_names = PackedStringArray(["Noto Sans CJK SC", "WenQuanYi Zen Hei", "Noto Sans", "Sans"])
	label.add_theme_font_override("font", system_font)
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", color)
	label.add_theme_color_override("font_outline_color", UIStyleGuide.BG_DARK)
	label.add_theme_constant_override("outline_size", 2)
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER

	return label


static func make_icon(kind: String, text: String = "") -> Control:
	return PixelIcon.new(kind, text)


static func make_inventory_slot(kind: String) -> PanelContainer:
	var slot := PixelPanel.new(UIStyleGuide.SLOT_SIZE, "normal", true)
	slot.custom_minimum_size = UIStyleGuide.SLOT_SIZE
	var icon := PixelIcon.new(kind, "")
	icon.custom_minimum_size = UIStyleGuide.ICON_COMPACT_SIZE
	slot.add_child(icon)
	return slot


static func make_shade_rect(alpha: float = 0.48) -> ColorRect:
	var shade := ColorRect.new()
	shade.set_anchors_preset(Control.PRESET_FULL_RECT)
	shade.color = Color(0.015, 0.012, 0.010, alpha)
	return shade


# === Icon Drawing Classes (kept for backward compatibility) ===

class PixelPanel extends PanelContainer:
	var frame_state: String = "normal"
	var compact: bool = false

	func _init(panel_size: Vector2 = Vector2.ZERO, panel_state: String = "normal", is_compact: bool = false) -> void:
		custom_minimum_size = panel_size
		frame_state = panel_state
		compact = is_compact
		add_theme_stylebox_override("panel", UIStyleGuide.compact_panel_style() if compact else UIStyleGuide.panel_style())
		mouse_filter = Control.MOUSE_FILTER_PASS

	func _ready() -> void:
		queue_redraw()

	func _draw() -> void:
		_draw_metal_frame(Rect2(Vector2.ZERO, size), frame_state)

	func _draw_metal_frame(rect: Rect2, state: String) -> void:
		if rect.size.x <= 4 or rect.size.y <= 4:
			return

		var border := UIStyleGuide.BORDER
		var bg := UIStyleGuide.PANEL_BG

		if state == "warning":
			border = UIStyleGuide.WARNING
		elif state == "danger":
			border = UIStyleGuide.DANGER
		elif state == "selected":
			border = UIStyleGuide.AVAILABLE
		elif state == "disabled":
			border = UIStyleGuide.BORDER_DARK
			bg = UIStyleGuide.PANEL_INSET.darkened(0.20)

		draw_rect(rect, Color(0.004, 0.004, 0.003, 0.86))
		draw_rect(Rect2(rect.position + Vector2(2, 2), rect.size - Vector2(4, 4)), UIStyleGuide.BORDER_DARK)
		draw_rect(Rect2(rect.position + Vector2(4, 4), rect.size - Vector2(8, 8)), border.darkened(0.30))
		draw_rect(Rect2(rect.position + Vector2(6, 6), rect.size - Vector2(12, 12)), bg)
		draw_rect(Rect2(rect.position + Vector2(8, 8), rect.size - Vector2(16, 16)), UIStyleGuide.PANEL_INSET.darkened(0.03))

		var inner := Rect2(rect.position + Vector2(7, 7), rect.size - Vector2(14, 14))
		draw_rect(Rect2(inner.position, Vector2(inner.size.x, 2)), border.lightened(0.16))
		draw_rect(Rect2(inner.position + Vector2(0, inner.size.y - 2), Vector2(inner.size.x, 2)), UIStyleGuide.BORDER_DARK)
		draw_rect(Rect2(inner.position, Vector2(2, inner.size.y)), UIStyleGuide.BORDER_DARK.lightened(0.14))
		draw_rect(Rect2(inner.position + Vector2(inner.size.x - 2, 0), Vector2(2, inner.size.y)), UIStyleGuide.BORDER_DARK.darkened(0.08))

		_draw_rivets(rect, border)
		_draw_scratches(rect)
		_draw_rust(rect)

	func _draw_rivets(rect: Rect2, color: Color) -> void:
		var pts := [
			rect.position + Vector2(7, 7),
			rect.position + Vector2(rect.size.x - 11, 7),
			rect.position + Vector2(7, rect.size.y - 11),
			rect.position + Vector2(rect.size.x - 11, rect.size.y - 11),
		]
		for p in pts:
			draw_rect(Rect2(p, Vector2(4, 4)), UIStyleGuide.BG_DARK)
			draw_rect(Rect2(p + Vector2(1, 1), Vector2(2, 2)), color.lightened(0.10))

	func _draw_scratches(rect: Rect2) -> void:
		var count := int(clampf(rect.size.x / 78.0, 2.0, 8.0))
		for i in range(count):
			var x := 18.0 + fmod(i * 47.0, maxf(20.0, rect.size.x - 38.0))
			var y := 14.0 + fmod(i * 29.0, maxf(18.0, rect.size.y - 32.0))
			var w := 8.0 + fmod(i * 5.0, 18.0)
			draw_rect(Rect2(rect.position + Vector2(x, y), Vector2(w, 1)), UIStyleGuide.TEXT_MUTED.darkened(0.18))
			if i % 2 == 0:
				draw_rect(Rect2(rect.position + Vector2(x + 3, y + 2), Vector2(w * 0.45, 1)), UIStyleGuide.BORDER_DARK)

	func _draw_rust(rect: Rect2) -> void:
		for i in range(5):
			var x := 10.0 + fmod(i * 61.0, maxf(16.0, rect.size.x - 24.0))
			var y := 5.0 if i % 2 == 0 else rect.size.y - 9.0
			draw_rect(Rect2(rect.position + Vector2(x, y), Vector2(7 + i % 3, 2)), UIStyleGuide.WARNING.darkened(0.28))


class PixelIcon extends Control:
	var icon_kind: String = "scrap"
	var value_text: String = ""

	func _init(kind: String, text: String = "") -> void:
		icon_kind = kind
		value_text = text
		custom_minimum_size = UIStyleGuide.ICON_FRAME_SIZE
		mouse_filter = Control.MOUSE_FILTER_IGNORE

	func _draw() -> void:
		_draw_frame(Rect2(Vector2.ZERO, size))
		_draw_symbol(Vector2(8, 6), icon_kind)
		if value_text != "":
			draw_string(ThemeDB.fallback_font, Vector2(31, 18), value_text, HORIZONTAL_ALIGNMENT_LEFT, size.x - 34, UIStyleGuide.FONT_SMALL, UIStyleGuide.TEXT)

	func _draw_frame(rect: Rect2) -> void:
		draw_rect(rect, UIStyleGuide.BG_DARK)
		draw_rect(Rect2(rect.position + Vector2(2, 2), rect.size - Vector2(4, 4)), UIStyleGuide.BORDER_DARK.lightened(0.20))
		draw_rect(Rect2(rect.position + Vector2(4, 4), rect.size - Vector2(8, 8)), UIStyleGuide.PANEL_INSET.lightened(0.03))

	func _draw_symbol(pos: Vector2, kind: String) -> void:
		if kind == "scrap":
			draw_rect(Rect2(pos + Vector2(0, 8), Vector2(14, 6)), UIStyleGuide.SCRAP)
			draw_rect(Rect2(pos + Vector2(7, 3), Vector2(8, 9)), Color(0.28, 0.27, 0.23))
			draw_rect(Rect2(pos + Vector2(2, 5), Vector2(5, 3)), UIStyleGuide.WARNING.darkened(0.18))
		elif kind == "fuel":
			draw_rect(Rect2(pos + Vector2(4, 1), Vector2(10, 16)), UIStyleGuide.DANGER.darkened(0.16))
			draw_rect(Rect2(pos + Vector2(6, 4), Vector2(6, 4)), UIStyleGuide.ENERGY.darkened(0.12))
			draw_rect(Rect2(pos + Vector2(14, 6), Vector2(3, 8)), UIStyleGuide.SCRAP.darkened(0.18))
		elif kind == "ammo":
			for i in range(3):
				draw_rect(Rect2(pos + Vector2(i * 5, 4), Vector2(3, 12)), UIStyleGuide.GOLD.darkened(0.16))
				draw_rect(Rect2(pos + Vector2(i * 5, 2), Vector2(3, 3)), UIStyleGuide.WARNING.darkened(0.28))
		elif kind == "coin":
			draw_rect(Rect2(pos + Vector2(4, 3), Vector2(10, 12)), UIStyleGuide.GOLD.darkened(0.10))
			draw_rect(Rect2(pos + Vector2(7, 5), Vector2(4, 8)), UIStyleGuide.GOLD.lightened(0.10))
		elif kind == "weapon":
			draw_rect(Rect2(pos + Vector2(2, 7), Vector2(15, 3)), UIStyleGuide.SCRAP.lightened(0.08))
			draw_rect(Rect2(pos + Vector2(12, 5), Vector2(6, 2)), UIStyleGuide.PANEL_INSET.lightened(0.12))
			draw_rect(Rect2(pos + Vector2(4, 10), Vector2(4, 5)), UIStyleGuide.WARNING.darkened(0.28))
		elif kind == "med":
			draw_rect(Rect2(pos + Vector2(3, 4), Vector2(13, 11)), UIStyleGuide.DANGER.darkened(0.12))
			draw_rect(Rect2(pos + Vector2(8, 5), Vector2(3, 9)), UIStyleGuide.TEXT.darkened(0.12))
			draw_rect(Rect2(pos + Vector2(5, 8), Vector2(9, 3)), UIStyleGuide.TEXT.darkened(0.12))
		elif kind == "mine":
			draw_rect(Rect2(pos + Vector2(4, 8), Vector2(12, 7)), UIStyleGuide.PANEL_INSET.lightened(0.08))
			draw_rect(Rect2(pos + Vector2(7, 5), Vector2(6, 3)), UIStyleGuide.SCRAP.lightened(0.08))
			draw_rect(Rect2(pos + Vector2(14, 6), Vector2(3, 2)), UIStyleGuide.WARNING)
		elif kind == "repair":
			draw_rect(Rect2(pos + Vector2(5, 4), Vector2(4, 13)), UIStyleGuide.SCRAP.lightened(0.20))
			draw_rect(Rect2(pos + Vector2(8, 3), Vector2(7, 4)), UIStyleGuide.SCRAP.darkened(0.05))
			draw_rect(Rect2(pos + Vector2(3, 13), Vector2(8, 3)), UIStyleGuide.WARNING.darkened(0.32))
		elif kind == "radio":
			draw_rect(Rect2(pos + Vector2(4, 6), Vector2(12, 10)), UIStyleGuide.ENERGY.darkened(0.10))
			draw_rect(Rect2(pos + Vector2(7, 9), Vector2(4, 3)), UIStyleGuide.BG_DARK.lightened(0.04))
			draw_line(pos + Vector2(13, 6), pos + Vector2(17, 1), UIStyleGuide.SCRAP.lightened(0.12), 2)
		else:
			draw_rect(Rect2(pos + Vector2(3, 3), Vector2(12, 12)), UIStyleGuide.ENERGY.darkened(0.08))
extends Node

const UIStyleGuide := preload("res://game/ui_style_guide.gd")
const WASTELAND_THEME := preload("res://themes/wasteland_ui_theme.tres")
const PIXEL_PANEL_SCENE := preload("res://scenes/ui/PixelMetalPanel.tscn")
const WASTELAND_BUTTON_SCENE := preload("res://scenes/ui/WastelandButton.tscn")
const WASTELAND_PROGRESS_SCENE := preload("res://scenes/ui/WastelandProgressBar.tscn")
const MUSIC_OPENING := "res://assets/audio/bgm/001_opening_theme.mp3"

const STATE_MENU := "menu"
const STATE_TOWN := "town"
const STATE_ROUTE := "route"
const STATE_BATTLE := "battle"
const STATE_GARAGE := "garage"
const STATE_RESULT := "result"

var COL_BG: Color = UIStyleGuide.BG_DARK
var COL_PANEL: Color = UIStyleGuide.PANEL_BG
var COL_LINE: Color = UIStyleGuide.BORDER
var COL_TEXT: Color = UIStyleGuide.TEXT
var COL_GOLD: Color = UIStyleGuide.GOLD
var COL_CYAN: Color = UIStyleGuide.CYAN
var COL_RED: Color = UIStyleGuide.DANGER

var system_font: SystemFont
var root: Control
var scene_layer: Control
var ui_layer: CanvasLayer
var state := STATE_MENU
var elapsed := 0.0

var scrap := 120
var fuel := 48
var rations := 16
var hunter_level := 1
var hunter_hp := 100
var tank_level := 1
var tank_armor := 120
var tank_max_armor := 120
var cannon_level := 1
var route_index := 0

var selected_route := {
	"name": "废弃加油站",
	"threat": 1,
	"fuel": 8,
	"reward": 38,
	"waves": 3,
}

var battle_time := 0.0
var battle_tick := 0.0
var wave := 1
var enemy_hp := 60
var enemy_max_hp := 60
var battle_log: Label
var battle_status: Label
var enemy_hp_bar: Control
var hunter_hp_bar: Control
var tank_hp_bar: Control
var result_text := ""
var result_scrap := 0
var result_xp := 0
var auto_battle_running := false

var music_player: AudioStreamPlayer
var opening_music_player: AudioStreamPlayer


class PixelPanel:
	extends PanelContainer

	var frame_state := "normal"
	var compact := false

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


class PixelMeter:
	extends Control

	var title := ""
	var current := 0
	var maximum := 100
	var fill_color := UIStyleGuide.DANGER
	var icon_kind := "hp"

	func _init(meter_title: String, value: int, max_value: int, color: Color, icon: String) -> void:
		title = meter_title
		current = value
		maximum = max(1, max_value)
		fill_color = color
		icon_kind = icon
		custom_minimum_size = UIStyleGuide.METER_SIZE
		mouse_filter = Control.MOUSE_FILTER_IGNORE

	func set_values(value: int, max_value: int) -> void:
		current = value
		maximum = max(1, max_value)
		queue_redraw()

	func _draw() -> void:
		var w := size.x
		var h := size.y
		var icon_w := 24.0
		_draw_icon(Vector2(0, 3), icon_kind)
		var bar := Rect2(icon_w + 6, 4, maxf(42.0, w - icon_w - 8), h - 8)
		_draw_pixel_frame(bar, UIStyleGuide.PANEL_INSET, UIStyleGuide.BORDER)
		var fill_w := floorf((bar.size.x - 8.0) * clampf(float(current) / float(maximum), 0.0, 1.0))
		if fill_w > 0.0:
			draw_rect(Rect2(bar.position + Vector2(4, 4), Vector2(fill_w, bar.size.y - 8)), fill_color.darkened(0.28))
			draw_rect(Rect2(bar.position + Vector2(4, 4), Vector2(fill_w, 2)), fill_color.lightened(0.12))
			draw_rect(Rect2(bar.position + Vector2(4, bar.size.y - 7), Vector2(fill_w, 2)), fill_color.darkened(0.45))
			for x in range(int(fill_w / 8.0)):
				draw_rect(Rect2(bar.position + Vector2(6 + x * 8, bar.size.y - 8), Vector2(3, 2)), fill_color.darkened(0.45 if x % 2 == 0 else 0.18))
		var font := ThemeDB.fallback_font
		var text := "%s  %d/%d" % [title, current, maximum]
		draw_string(font, bar.position + Vector2(8, 16), text, HORIZONTAL_ALIGNMENT_LEFT, bar.size.x - 16, UIStyleGuide.FONT_SMALL, UIStyleGuide.TEXT)

	func _draw_pixel_frame(rect: Rect2, bg: Color, border: Color) -> void:
		draw_rect(rect, UIStyleGuide.BG_DARK)
		draw_rect(Rect2(rect.position + Vector2(2, 2), rect.size - Vector2(4, 4)), UIStyleGuide.BORDER_DARK)
		draw_rect(Rect2(rect.position + Vector2(4, 4), rect.size - Vector2(8, 8)), bg)
		draw_rect(Rect2(rect.position + Vector2(4, 4), Vector2(rect.size.x - 8, 2)), border.lightened(0.25))
		draw_rect(Rect2(rect.position + Vector2(4, rect.size.y - 6), Vector2(rect.size.x - 8, 2)), border.darkened(0.35))
		for i in range(4):
			var x := rect.position.x + 10 + i * maxf(18.0, rect.size.x / 5.0)
			if x < rect.position.x + rect.size.x - 14:
				draw_rect(Rect2(x, rect.position.y + rect.size.y - 8, 4, 1), UIStyleGuide.WARNING.darkened(0.30))

	func _draw_icon(pos: Vector2, kind: String) -> void:
		var outline := UIStyleGuide.BG_DARK
		var metal := UIStyleGuide.SCRAP
		draw_rect(Rect2(pos, Vector2(22, 22)), outline)
		draw_rect(Rect2(pos + Vector2(2, 2), Vector2(18, 18)), UIStyleGuide.PANEL_INSET.lightened(0.08))
		if kind == "hp":
			draw_rect(Rect2(pos + Vector2(7, 4), Vector2(8, 14)), UIStyleGuide.HP.lightened(0.12))
			draw_rect(Rect2(pos + Vector2(4, 7), Vector2(14, 8)), UIStyleGuide.HP.lightened(0.12))
			draw_rect(Rect2(pos + Vector2(8, 5), Vector2(5, 3)), UIStyleGuide.WARNING)
		elif kind == "energy":
			draw_rect(Rect2(pos + Vector2(9, 3), Vector2(6, 7)), UIStyleGuide.STAMINA.darkened(0.05))
			draw_rect(Rect2(pos + Vector2(6, 9), Vector2(6, 10)), UIStyleGuide.STAMINA.lightened(0.22))
			draw_rect(Rect2(pos + Vector2(11, 9), Vector2(5, 5)), UIStyleGuide.BORDER_DARK)
		elif kind == "tank":
			draw_rect(Rect2(pos + Vector2(4, 9), Vector2(13, 7)), metal)
			draw_rect(Rect2(pos + Vector2(7, 6), Vector2(7, 4)), metal.lightened(0.22))
			draw_rect(Rect2(pos + Vector2(14, 7), Vector2(6, 2)), metal.darkened(0.25))
			draw_rect(Rect2(pos + Vector2(5, 15), Vector2(11, 3)), UIStyleGuide.BG_DARK.lightened(0.04))
		else:
			draw_rect(Rect2(pos + Vector2(5, 5), Vector2(12, 12)), UIStyleGuide.CYAN.darkened(0.12))


class PixelIcon:
	extends Control

	var icon_kind := "scrap"
	var value_text := ""

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


class WastelandScene:
	extends Control

	const TILE := 16.0
	const PIX := 3.0

	var mode := "town"
	var t := 0.0

	func _init(scene_mode: String) -> void:
		mode = scene_mode
		mouse_filter = Control.MOUSE_FILTER_IGNORE

	func _process(delta: float) -> void:
		t += delta
		queue_redraw()

	func _draw() -> void:
		var w := size.x
		var h := size.y
		if w <= 0 or h <= 0:
			return

		_draw_pixel_sky(w, h)
		_draw_background_layers(w, h)
		var ground_y: float = floorf(h * 0.62 / TILE) * TILE
		_draw_tile_terrain(w, h, ground_y)

		if mode == "town":
			_draw_town(w, h, ground_y)
		elif mode == "battle":
			_draw_battle(w, h, ground_y)
		else:
			_draw_route(w, h, ground_y)

		for i in range(80):
			var x: float = floorf(fmod(i * 61.0 + t * (18.0 + fmod(i, 5) * 6.0), w) / 2.0) * 2.0
			var y: float = floorf(fmod(i * 37.0 + sin(t + i) * 8.0, h * 0.80) / 2.0) * 2.0
			draw_rect(Rect2(x, y, 2, 2), Color(0.70, 0.50, 0.27, 0.18))

	func _draw_pixel_sky(w: float, h: float) -> void:
		var bands := [
			[0.00, Color(0.09, 0.055, 0.038)],
			[0.18, Color(0.14, 0.075, 0.045)],
			[0.34, Color(0.25, 0.115, 0.058)],
			[0.50, Color(0.40, 0.185, 0.075)],
			[0.62, Color(0.24, 0.14, 0.075)],
		]
		for i in range(bands.size()):
			var y0: float = floorf(float(bands[i][0]) * h / TILE) * TILE
			var y1: float = h if i == bands.size() - 1 else floorf(float(bands[i + 1][0]) * h / TILE) * TILE
			draw_rect(Rect2(0, y0, w, y1 - y0), bands[i][1])

		var sx: float = floorf(w * 0.62 / TILE) * TILE
		var sy: float = floorf(h * 0.24 / TILE) * TILE
		var sun_col := Color(0.90, 0.48, 0.18, 0.48)
		for y in range(4):
			for x in range(5):
				if abs(x - 2) + abs(y - 1) < 4:
					draw_rect(Rect2(sx + x * TILE, sy + y * TILE, TILE, TILE), sun_col)
		for i in range(8):
			var px := fmod(i * 181.0, w)
			var py: float = floorf((h * 0.12 + fmod(i * 47.0, h * 0.25)) / TILE) * TILE
			draw_rect(Rect2(px, py, TILE * (2 + i % 4), TILE), Color(0.11, 0.08, 0.065, 0.28))

	func _draw_background_layers(w: float, h: float) -> void:
		var gy: float = floorf(h * 0.62 / TILE) * TILE
		for i in range(14):
			var x := fmod(i * 137.0 - 40.0, w + 80.0) - 40.0
			var height := TILE * (4 + i % 6)
			var y: float = gy - height - TILE * (i % 3)
			var pts := PackedVector2Array([
				Vector2(x, gy),
				Vector2(x + TILE * 2, y + TILE * 2),
				Vector2(x + TILE * 4, y),
				Vector2(x + TILE * 7, gy),
			])
			draw_colored_polygon(pts, Color(0.105, 0.083, 0.065, 0.70))
		for i in range(10):
			var x := fmod(i * 151.0 + 40.0, w)
			var y: float = gy - TILE * (5 + i % 5)
			draw_rect(Rect2(x, y, TILE * (2 + i % 3), TILE * (5 + i % 5)), Color(0.075, 0.066, 0.058, 0.72))
			draw_rect(Rect2(x + TILE * 0.5, y + TILE, TILE * 0.5, TILE * 0.5), Color(0.55, 0.34, 0.12, 0.18))
			draw_rect(Rect2(x + TILE * 1.4, y + TILE * 2.5, TILE * 0.5, TILE * 0.5), Color(0.10, 0.22, 0.20, 0.25))
		for i in range(6):
			var px := fmod(i * 223.0 + 80.0, w)
			var py: float = gy - TILE * (5 + i % 3)
			draw_rect(Rect2(px, py, TILE * 0.25, TILE * 6), Color(0.055, 0.048, 0.042, 0.84))
			draw_line(Vector2(px, py), Vector2(px + TILE * 5, py + TILE * 1.2), Color(0.045, 0.040, 0.035, 0.70), 2.0)

	func _draw_tile_terrain(w: float, h: float, gy: float) -> void:
		var cols := int(ceil(w / TILE)) + 1
		var rows := int(ceil((h - gy) / TILE)) + 2
		for x in range(cols):
			var crest := 0
			if x % 9 == 2:
				crest = -1
			elif x % 13 == 5:
				crest = 1
			for y in range(rows):
				var pos := Vector2(x * TILE, gy + (y + crest) * TILE)
				if pos.y < gy - TILE:
					continue
				var kind := "sand"
				if y > 1:
					kind = "dirt"
				if y > 5:
					kind = "wall"
				if (x * 7 + y * 11) % 17 == 0:
					kind = "rock"
				if (x * 5 + y * 3) % 23 == 0 and y < 5:
					kind = "metal"
				_draw_tile(pos, kind, x + y * 37)
		for x in range(cols):
			if x % 5 == 0:
				_draw_tile(Vector2(x * TILE, gy - TILE), "dry_grass", x)

	func _draw_tile(pos: Vector2, kind: String, seed: int) -> void:
		var base := Color(0.43, 0.29, 0.13)
		var dark := Color(0.23, 0.15, 0.08)
		var light := Color(0.64, 0.43, 0.20)
		if kind == "dirt":
			base = Color(0.28, 0.18, 0.105)
			dark = Color(0.16, 0.105, 0.070)
			light = Color(0.39, 0.26, 0.14)
		elif kind == "rock":
			base = Color(0.23, 0.21, 0.18)
			dark = Color(0.12, 0.11, 0.10)
			light = Color(0.38, 0.35, 0.29)
		elif kind == "metal":
			base = Color(0.32, 0.30, 0.25)
			dark = Color(0.12, 0.115, 0.10)
			light = Color(0.58, 0.52, 0.40)
		elif kind == "wall":
			base = Color(0.18, 0.14, 0.115)
			dark = Color(0.095, 0.075, 0.062)
			light = Color(0.27, 0.21, 0.16)
		elif kind == "dry_grass":
			draw_rect(Rect2(pos + Vector2(4, 9), Vector2(2, 7)), Color(0.55, 0.40, 0.16))
			draw_rect(Rect2(pos + Vector2(8, 6), Vector2(2, 10)), Color(0.62, 0.46, 0.18))
			draw_rect(Rect2(pos + Vector2(11, 11), Vector2(2, 5)), Color(0.47, 0.33, 0.14))
			return
		draw_rect(Rect2(pos, Vector2(TILE, TILE)), base)
		draw_rect(Rect2(pos, Vector2(TILE, 2)), light)
		draw_rect(Rect2(pos + Vector2(0, TILE - 3), Vector2(TILE, 3)), dark)
		draw_rect(Rect2(pos + Vector2(TILE - 2, 0), Vector2(2, TILE)), dark)
		for i in range(3):
			var px := 2 + ((seed + i * 5) % 11)
			var py := 4 + ((seed * 3 + i * 7) % 9)
			draw_rect(Rect2(pos + Vector2(px, py), Vector2(2 + seed % 3, 2)), light.darkened(0.18))
		if kind == "metal":
			draw_rect(Rect2(pos + Vector2(3, 4), Vector2(10, 2)), Color(0.62, 0.23, 0.09))
			draw_rect(Rect2(pos + Vector2(10, 10), Vector2(3, 3)), Color(0.10, 0.34, 0.31))

	func _draw_town(w: float, h: float, gy: float) -> void:
		_building(Vector2(floor(w * 0.10 / TILE) * TILE, gy - TILE * 8), Vector2(TILE * 14, TILE * 8), "GARAGE", Color(0.18, 0.13, 0.10))
		_building(Vector2(floor(w * 0.34 / TILE) * TILE, gy - TILE * 6), Vector2(TILE * 10, TILE * 6), "BAR", Color(0.16, 0.105, 0.085))
		_building(Vector2(floor(w * 0.56 / TILE) * TILE, gy - TILE * 7), Vector2(TILE * 12, TILE * 7), "SHOP", Color(0.145, 0.118, 0.092))
		_draw_repair_point(Vector2(w * 0.26, gy - TILE * 2))
		_draw_road_sign(Vector2(w * 0.72, gy - TILE * 3), "WEST")
		_draw_utility_pole(Vector2(w * 0.80, gy - TILE * 8))
		_draw_oil_drums(Vector2(w * 0.48, gy - TILE * 2), 4)
		_draw_scrap_heap(Vector2(w * 0.67, gy - TILE * 3))
		_draw_tank(Vector2(w * 0.20, gy - TILE * 3), 3.0)
		_draw_hunter(Vector2(w * 0.42, gy - TILE * 4), 3.0, true)
		_draw_npc(Vector2(w * 0.36, gy - TILE * 4), 3.0)

	func _draw_battle(w: float, h: float, gy: float) -> void:
		_building(Vector2(floor(w * 0.56 / TILE) * TILE, gy - TILE * 7), Vector2(TILE * 15, TILE * 7), "FUEL", Color(0.17, 0.095, 0.070))
		_draw_oil_drums(Vector2(w * 0.72, gy - TILE * 2), 5)
		_draw_scrap_heap(Vector2(w * 0.50, gy - TILE * 3))
		_draw_tank(Vector2(w * 0.16 + floor(sin(t * 2.0) * 2.0), gy - TILE * 3), 3.2)
		_draw_hunter(Vector2(w * 0.31, gy - TILE * 4), 3.0, true)
		_draw_mech_dog(Vector2(w * 0.63 + floor(sin(t * 6.0) * 3.0), gy - TILE * 3), 3.0)
		_draw_mutant_bug(Vector2(w * 0.72, gy - TILE * 2.5), 2.4)
		_draw_scrap_drone(Vector2(w * 0.76, gy - TILE * 7 + floor(sin(t * 4.0) * 5.0)), 2.4)

	func _draw_route(w: float, h: float, gy: float) -> void:
		for i in range(5):
			var p := Vector2(floor(w * (0.18 + i * 0.15) / TILE) * TILE, gy + floor(sin(i * 1.6) * 3.0) * TILE)
			_draw_tile(p - Vector2(TILE, TILE), "metal", i)
			draw_rect(Rect2(p - Vector2(6, 6), Vector2(12, 12)), Color(0.85, 0.55, 0.20))
			if i < 4:
				var n := Vector2(floor(w * (0.18 + (i + 1) * 0.15) / TILE) * TILE, gy + floor(sin((i + 1) * 1.6) * 3.0) * TILE)
				draw_line(p, n, Color(0.66, 0.42, 0.17, 0.88), 4.0)
				for step in range(5):
					var q := p.lerp(n, step / 5.0)
					draw_rect(Rect2(floor(q.x / 4.0) * 4.0, floor(q.y / 4.0) * 4.0, 6, 6), Color(0.26, 0.18, 0.10))
		_draw_tank(Vector2(w * 0.18, gy - TILE * 5), 2.2)

	func _building(pos: Vector2, s: Vector2, title: String, col: Color) -> void:
		draw_rect(Rect2(pos + Vector2(TILE * 0.5, s.y), Vector2(s.x, TILE * 0.5)), Color(0.02, 0.018, 0.014, 0.40))
		var cols := int(s.x / TILE)
		var rows := int(s.y / TILE)
		for x in range(cols):
			for y in range(rows):
				var kind := "wall"
				if x == 0 or x == cols - 1 or y == 0:
					kind = "metal"
				_draw_tile(pos + Vector2(x * TILE, y * TILE), kind, x + y * 17)
		draw_rect(Rect2(pos + Vector2(TILE, TILE * 2), Vector2(TILE * 3, s.y - TILE * 2)), Color(0.045, 0.040, 0.035))
		draw_rect(Rect2(pos + Vector2(s.x - TILE * 4, TILE * 2), Vector2(TILE * 2, TILE * 1.5)), Color(0.055, 0.28, 0.25, 0.86))
		for i in range(3):
			draw_rect(Rect2(pos + Vector2(TILE * (2 + i * 3), TILE * 0.45), Vector2(TILE * 1.5, TILE * 0.35)), Color(0.72, 0.28, 0.10))
		var sign_width: float = minf(s.x - TILE * 2, title.length() * 12.0)
		draw_rect(Rect2(pos + Vector2(TILE, -TILE), Vector2(sign_width, TILE)), Color(0.68, 0.43, 0.16))
		draw_rect(Rect2(pos + Vector2(TILE + 4, -TILE + 5), Vector2(sign_width - 8, 4)), Color(0.08, 0.06, 0.045))

	func _px(pos: Vector2, x: float, y: float, w: float, h: float, color: Color, scale: float) -> void:
		draw_rect(Rect2(pos + Vector2(x, y) * scale, Vector2(w, h) * scale), color)

	func _draw_tank(pos: Vector2, scale: float) -> void:
		var s := scale
		_px(pos, -2, 19, 56, 5, Color(0.02, 0.018, 0.014, 0.46), s)
		_px(pos, 0, 8, 47, 13, Color(0.055, 0.058, 0.050), s)
		_px(pos, 2, 5, 35, 13, Color(0.30, 0.34, 0.30), s)
		_px(pos, 7, 0, 22, 8, Color(0.40, 0.45, 0.39), s)
		_px(pos, 27, 3, 26, 3, Color(0.15, 0.17, 0.15), s)
		_px(pos, 52, 2, 3, 5, Color(0.09, 0.10, 0.09), s)
		_px(pos, 4, 16, 39, 7, Color(0.045, 0.043, 0.038), s)
		for i in range(6):
			_px(pos, 5 + i * 6, 15, 5, 5, Color(0.14, 0.15, 0.13), s)
			_px(pos, 7 + i * 6, 17, 2, 2, Color(0.56, 0.57, 0.49), s)
		_px(pos, 9, 8, 9, 2, Color(0.70, 0.68, 0.54), s)
		_px(pos, 20, 6, 4, 4, Color(0.08, 0.24, 0.22), s)
		_px(pos, 34, 9, 5, 2, Color(0.70, 0.25, 0.08), s)
		_px(pos, 41, 11, 4, 2, Color(0.66, 0.22, 0.07), s)
		_px(pos, 30, -5, 2, 7, Color(0.05, 0.045, 0.040), s)
		_px(pos, 32, -5 + floor(sin(t * 5.0) * 1.0), 8, 4, Color(0.78, 0.16, 0.08), s)

	func _draw_hunter(pos: Vector2, scale: float, walking: bool) -> void:
		var s := scale
		var frame := int(t * 5.0) % 2 if walking else 0
		var bob := float(frame)
		_px(pos, 1, 17, 12, 3, Color(0.02, 0.018, 0.014, 0.45), s)
		_px(pos, 4, 0 + bob, 6, 5, Color(0.78, 0.54, 0.34), s)
		_px(pos, 3, 5 + bob, 8, 9, Color(0.62, 0.15, 0.09), s)
		_px(pos, 2, 7 + bob, 3, 7, Color(0.13, 0.12, 0.105), s)
		_px(pos, 10, 7 + bob, 3, 6, Color(0.13, 0.12, 0.105), s)
		_px(pos, 4, 14 + bob, 3, 5 + frame, Color(0.055, 0.052, 0.045), s)
		_px(pos, 8, 14 + bob, 3, 6 - frame, Color(0.055, 0.052, 0.045), s)
		_px(pos, 5, 1 + bob, 5, 2, Color(0.20, 0.14, 0.10), s)
		_px(pos, 6, 3 + bob, 1, 1, Color(0.02, 0.018, 0.014), s)
		_px(pos, 9, 3 + bob, 1, 1, Color(0.02, 0.018, 0.014), s)
		_px(pos, 12, 8 + bob, 5, 2, Color(0.18, 0.17, 0.14), s)

	func _draw_npc(pos: Vector2, scale: float) -> void:
		var s := scale
		var bob: float = floorf(sin(t * 3.0))
		_px(pos, 1, 17, 12, 3, Color(0.02, 0.018, 0.014, 0.45), s)
		_px(pos, 4, 0 + bob, 6, 5, Color(0.78, 0.54, 0.34), s)
		_px(pos, 3, 5 + bob, 8, 9, Color(0.76, 0.47, 0.18), s)
		_px(pos, 1, 7 + bob, 4, 7, Color(0.18, 0.17, 0.14), s)
		_px(pos, 10, 7 + bob, 4, 6, Color(0.18, 0.17, 0.14), s)
		_px(pos, 5, 14 + bob, 3, 5, Color(0.055, 0.052, 0.045), s)
		_px(pos, 9, 14 + bob, 3, 5, Color(0.055, 0.052, 0.045), s)
		_px(pos, 11, 9 + bob, 5, 2, Color(0.58, 0.58, 0.50), s)

	func _draw_mech_dog(pos: Vector2, scale: float) -> void:
		var s := scale
		var frame := int(t * 7.0) % 2
		_px(pos, 0, 11, 22, 4, Color(0.02, 0.018, 0.014, 0.45), s)
		_px(pos, 2, 4, 14, 7, Color(0.45, 0.12, 0.09), s)
		_px(pos, 15, 2, 7, 6, Color(0.58, 0.15, 0.10), s)
		_px(pos, 20, 5, 4, 2, Color(0.86, 0.70, 0.38), s)
		_px(pos, 6, 2, 6, 2, Color(0.42, 0.40, 0.34), s)
		for i in range(4):
			_px(pos, 4 + i * 4, 10, 2, 5 + ((i + frame) % 2), Color(0.06, 0.055, 0.050), s)
		_px(pos, 0, 5 + frame, 4, 2, Color(0.35, 0.09, 0.07), s)

	func _draw_mutant_bug(pos: Vector2, scale: float) -> void:
		var s := scale
		var bob: float = floorf(sin(t * 8.0))
		_px(pos, 0, 10, 18, 4, Color(0.02, 0.018, 0.014, 0.45), s)
		_px(pos, 2, 4 + bob, 13, 7, Color(0.34, 0.42, 0.18), s)
		_px(pos, 13, 3 + bob, 5, 5, Color(0.50, 0.58, 0.24), s)
		for i in range(6):
			_px(pos, 3 + i * 2, 10 + bob, 1, 4, Color(0.08, 0.07, 0.05), s)
		_px(pos, 16, 5 + bob, 2, 1, Color(0.95, 0.75, 0.18), s)

	func _draw_scrap_drone(pos: Vector2, scale: float) -> void:
		var s := scale
		_px(pos, 1, 6, 18, 3, Color(0.02, 0.018, 0.014, 0.18), s)
		_px(pos, 5, 4, 10, 7, Color(0.33, 0.32, 0.28), s)
		_px(pos, 8, 6, 4, 2, Color(0.16, 0.75, 0.68), s)
		_px(pos, 0, 5, 5, 2, Color(0.10, 0.09, 0.08), s)
		_px(pos, 15, 5, 5, 2, Color(0.10, 0.09, 0.08), s)
		_px(pos, 6, 11, 2, 4, Color(0.74, 0.35, 0.12, 0.55), s)
		_px(pos, 12, 11, 2, 4, Color(0.74, 0.35, 0.12, 0.55), s)

	func _draw_repair_point(pos: Vector2) -> void:
		draw_rect(Rect2(pos + Vector2(0, TILE * 2), Vector2(TILE * 5, TILE * 0.5)), Color(0.02, 0.018, 0.014, 0.40))
		for i in range(4):
			_draw_tile(pos + Vector2(i * TILE, TILE), "metal", i)
		draw_rect(Rect2(pos + Vector2(TILE * 1.2, 0), Vector2(TILE * 2.5, TILE)), Color(0.55, 0.20, 0.08))
		draw_rect(Rect2(pos + Vector2(TILE * 1.7, 4), Vector2(TILE * 1.5, 4)), Color(0.10, 0.08, 0.06))

	func _draw_road_sign(pos: Vector2, _text: String) -> void:
		draw_rect(Rect2(pos + Vector2(8, 0), Vector2(4, TILE * 3)), Color(0.10, 0.08, 0.06))
		draw_rect(Rect2(pos + Vector2(-TILE, 4), Vector2(TILE * 3, TILE)), Color(0.42, 0.25, 0.10))
		draw_rect(Rect2(pos + Vector2(-10, 9), Vector2(TILE * 2.2, 3)), Color(0.10, 0.07, 0.05))

	func _draw_utility_pole(pos: Vector2) -> void:
		draw_rect(Rect2(pos, Vector2(5, TILE * 8)), Color(0.09, 0.07, 0.055))
		draw_rect(Rect2(pos + Vector2(-TILE, TILE), Vector2(TILE * 2.5, 4)), Color(0.10, 0.08, 0.06))
		draw_line(pos + Vector2(-TILE * 5, TILE * 1.2), pos + Vector2(TILE * 6, TILE * 2.0), Color(0.04, 0.035, 0.032), 2.0)
		draw_line(pos + Vector2(-TILE * 5, TILE * 2.0), pos + Vector2(TILE * 6, TILE * 2.8), Color(0.04, 0.035, 0.032), 2.0)

	func _draw_oil_drums(pos: Vector2, count: int) -> void:
		for i in range(count):
			var p := pos + Vector2(i * TILE * 0.85, (i % 2) * 4)
			draw_rect(Rect2(p, Vector2(12, 22)), Color(0.36, 0.08, 0.05))
			draw_rect(Rect2(p + Vector2(2, 2), Vector2(8, 3)), Color(0.72, 0.20, 0.07))
			draw_rect(Rect2(p + Vector2(2, 12), Vector2(8, 2)), Color(0.18, 0.06, 0.04))

	func _draw_scrap_heap(pos: Vector2) -> void:
		for i in range(8):
			var p := pos + Vector2((i % 4) * 14, -floor(i / 4.0) * 12 + (i % 2) * 4)
			var kind := "metal" if i % 2 == 0 else "rock"
			_draw_tile(p, kind, i * 11)


func _ready() -> void:
	get_window().title = "横板像素废土放置 RPG"
	get_viewport().canvas_item_default_texture_filter = Viewport.DEFAULT_CANVAS_ITEM_TEXTURE_FILTER_NEAREST
	_init_font()
	_register_input()
	_build_audio()
	_build_root()
	_switch_state(STATE_MENU)


func _process(delta: float) -> void:
	elapsed += delta
	if state == STATE_BATTLE:
		_update_auto_battle(delta)


func _init_font() -> void:
	system_font = SystemFont.new()
	system_font.font_names = PackedStringArray(["Noto Sans CJK SC", "WenQuanYi Zen Hei", "Noto Sans", "Sans"])


func _register_input() -> void:
	_ensure_key("ui_accept", KEY_SPACE)
	_ensure_key("ui_accept", KEY_ENTER)
	_ensure_key("ui_cancel", KEY_ESCAPE)


func _ensure_key(action: StringName, keycode: Key) -> void:
	if not InputMap.has_action(action):
		InputMap.add_action(action)
	var event := InputEventKey.new()
	event.keycode = keycode
	for existing in InputMap.action_get_events(action):
		if existing is InputEventKey and existing.keycode == keycode:
			return
	InputMap.action_add_event(action, event)


func _build_audio() -> void:
	opening_music_player = AudioStreamPlayer.new()
	opening_music_player.name = "OpeningMusic"
	opening_music_player.volume_db = -10.0
	add_child(opening_music_player)
	if FileAccess.file_exists(MUSIC_OPENING):
		var stream := AudioStreamMP3.new()
		stream.data = FileAccess.get_file_as_bytes(MUSIC_OPENING)
		opening_music_player.stream = stream
		opening_music_player.play()


func _build_root() -> void:
	root = Control.new()
	root.name = "GameRoot"
	root.set_anchors_preset(Control.PRESET_FULL_RECT)
	root.theme = WASTELAND_THEME
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
	state = next_state
	elapsed = 0.0
	_clear(scene_layer)
	_clear(ui_layer)
	auto_battle_running = false

	if next_state == STATE_MENU:
		_build_menu()
	elif next_state == STATE_TOWN:
		_build_town()
	elif next_state == STATE_ROUTE:
		_build_route_map()
	elif next_state == STATE_BATTLE:
		_build_battle()
	elif next_state == STATE_GARAGE:
		_build_garage()
	elif next_state == STATE_RESULT:
		_build_result()


func _build_menu() -> void:
	_add_scene("town")
	var shade := ColorRect.new()
	shade.set_anchors_preset(Control.PRESET_FULL_RECT)
	shade.color = Color(0.015, 0.012, 0.010, 0.48)
	ui_layer.add_child(shade)

	var title := _make_label("荒原战车：放置远征", 62, UIStyleGuide.GOLD)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.set_anchors_preset(Control.PRESET_CENTER)
	title.offset_left = -430
	title.offset_top = -190
	title.offset_right = 430
	title.offset_bottom = -110
	ui_layer.add_child(title)

	var subtitle := _make_label("横板像素废土放置 RPG", 22, UIStyleGuide.CYAN)
	subtitle.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	subtitle.set_anchors_preset(Control.PRESET_CENTER)
	subtitle.offset_left = -280
	subtitle.offset_top = -104
	subtitle.offset_right = 280
	subtitle.offset_bottom = -64
	ui_layer.add_child(subtitle)

	var menu := VBoxContainer.new()
	menu.set_anchors_preset(Control.PRESET_CENTER)
	menu.offset_left = -150
	menu.offset_top = -28
	menu.offset_right = 150
	menu.offset_bottom = 160
	menu.add_theme_constant_override("separation", 10)
	ui_layer.add_child(menu)
	menu.add_child(_make_button("进入城镇 Hub", _switch_state.bind(STATE_TOWN), Vector2(300, 48), 18))
	menu.add_child(_make_button("路线地图", _switch_state.bind(STATE_ROUTE), Vector2(300, 48), 18))
	menu.add_child(_make_button("车库升级", _switch_state.bind(STATE_GARAGE), Vector2(300, 48), 18))

	var version := _make_label("v2 prototype · 城镇 → 路线 → 自动战斗 → 资源 → 升级 → 新区域", UIStyleGuide.FONT_BODY, UIStyleGuide.TEXT_MUTED)
	version.set_anchors_preset(Control.PRESET_BOTTOM_LEFT)
	version.offset_left = 20
	version.offset_top = -34
	version.offset_right = 620
	version.offset_bottom = -12
	ui_layer.add_child(version)


func _build_town() -> void:
	_add_scene("town")
	_build_game_frame("锈镇 Hub", "整备、升级、选择路线")
	_add_right_panel("城镇情报", [
		"解锁区域：3",
		"可挑战路线：废弃加油站 / 干涸河床 / 雷达废墟",
		"当前循环：选择路线后自动战斗，胜利结算资源。",
	])
	_add_bottom_bar([
		{"text": "路线地图", "call": _switch_state.bind(STATE_ROUTE)},
		{"text": "车库升级", "call": _switch_state.bind(STATE_GARAGE)},
		{"text": "开始推荐路线", "call": _start_route.bind(0)},
		{"text": "主菜单", "call": _switch_state.bind(STATE_MENU)},
	])

	var town_panel := _make_panel(Vector2(430, 150))
	town_panel.set_anchors_preset(Control.PRESET_BOTTOM_LEFT)
	town_panel.offset_left = 22
	town_panel.offset_top = -236
	town_panel.offset_right = 452
	town_panel.offset_bottom = -86
	ui_layer.add_child(town_panel)
	var copy := _make_label("马库斯修理站\n战车还能跑，但每次远征都要消耗燃料。先打低威胁路线攒废金属，再升级装甲和主炮。", 16, COL_TEXT)
	copy.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	town_panel.add_child(copy)


func _build_route_map() -> void:
	_add_scene("route")
	_build_game_frame("路线地图", "选择路线 → 自动战斗")
	_add_right_panel("路线规则", [
		"路线消耗燃料并产出废金属与经验。",
		"威胁越高，敌人血量和波次越高。",
		"胜利后进入结算界面；失败会带着少量残骸返回城镇。",
	])

	var routes := [
		{"name": "废弃加油站", "threat": 1, "fuel": 8, "reward": 38, "waves": 3},
		{"name": "干涸河床", "threat": 2, "fuel": 12, "reward": 62, "waves": 4},
		{"name": "雷达废墟", "threat": 3, "fuel": 18, "reward": 96, "waves": 5},
	]
	var list := VBoxContainer.new()
	list.set_anchors_preset(Control.PRESET_LEFT_WIDE)
	list.offset_left = 26
	list.offset_top = 84
	list.offset_right = 430
	list.offset_bottom = -92
	list.add_theme_constant_override("separation", 10)
	ui_layer.add_child(list)

	for i in range(routes.size()):
		var r: Dictionary = routes[i]
		var b := _make_button("%s  威胁%d  燃料-%d  奖励%d" % [r["name"], r["threat"], r["fuel"], r["reward"]], _start_route.bind(i), Vector2(400, 52), 15)
		list.add_child(b)

	_add_bottom_bar([
		{"text": "返回城镇", "call": _switch_state.bind(STATE_TOWN)},
		{"text": "车库升级", "call": _switch_state.bind(STATE_GARAGE)},
	])


func _start_route(index: int) -> void:
	var routes := [
		{"name": "废弃加油站", "threat": 1, "fuel": 8, "reward": 38, "waves": 3},
		{"name": "干涸河床", "threat": 2, "fuel": 12, "reward": 62, "waves": 4},
		{"name": "雷达废墟", "threat": 3, "fuel": 18, "reward": 96, "waves": 5},
	]
	route_index = index
	selected_route = routes[index]
	if fuel < int(selected_route["fuel"]):
		result_text = "燃料不足，远征取消。"
		result_scrap = 0
		result_xp = 0
		_switch_state(STATE_RESULT)
		return
	fuel -= int(selected_route["fuel"])
	_switch_state(STATE_BATTLE)


func _build_battle() -> void:
	_add_scene("battle")
	_build_game_frame(str(selected_route["name"]), "自动战斗中")
	_add_right_panel("战斗信息", [
		"模式：自动普攻 / 主炮冷却触发",
		"路线威胁：%d" % int(selected_route["threat"]),
		"敌方波次：%d" % int(selected_route["waves"]),
	])
	_add_bottom_bar([
		{"text": "加速结算", "call": _finish_battle.bind(true)},
		{"text": "撤退", "call": _finish_battle.bind(false)},
	])

	battle_time = 0.0
	battle_tick = 0.0
	wave = 1
	enemy_max_hp = 46 + int(selected_route["threat"]) * 26
	enemy_hp = enemy_max_hp
	auto_battle_running = true

	var panel := _make_panel(Vector2(360, 178))
	panel.set_anchors_preset(Control.PRESET_TOP_LEFT)
	panel.offset_left = 24
	panel.offset_top = 104
	panel.offset_right = 384
	panel.offset_bottom = 282
	ui_layer.add_child(panel)
	var col := VBoxContainer.new()
	col.add_theme_constant_override("separation", 10)
	panel.add_child(col)
	battle_status = _make_label("", 16, COL_GOLD)
	col.add_child(battle_status)
	hunter_hp_bar = _make_progress("猎人", hunter_hp, 100, UIStyleGuide.HP, "hp")
	col.add_child(hunter_hp_bar)
	tank_hp_bar = _make_progress("战车", tank_armor, tank_max_armor, UIStyleGuide.ARMOR, "tank")
	col.add_child(tank_hp_bar)
	enemy_hp_bar = _make_progress("敌方", enemy_hp, enemy_max_hp, UIStyleGuide.DANGER, "enemy")
	col.add_child(enemy_hp_bar)

	var log_panel := _make_panel(Vector2(460, 116))
	log_panel.set_anchors_preset(Control.PRESET_BOTTOM_LEFT)
	log_panel.offset_left = 24
	log_panel.offset_top = -212
	log_panel.offset_right = 484
	log_panel.offset_bottom = -96
	ui_layer.add_child(log_panel)
	battle_log = _make_label("引擎低吼，战车驶入交战区。", 15, COL_TEXT)
	battle_log.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	log_panel.add_child(battle_log)
	_refresh_battle_ui()


func _update_auto_battle(delta: float) -> void:
	if not auto_battle_running:
		return
	battle_time += delta
	battle_tick += delta
	if battle_tick < 0.72:
		return
	battle_tick = 0.0

	var threat := int(selected_route["threat"])
	var cannon_hit := 18 + cannon_level * 8 + tank_level * 4
	var hunter_hit := 7 + hunter_level * 3
	var damage := hunter_hit
	var line := "猎人点射造成 %d 伤害。" % hunter_hit
	if int(battle_time * 10.0) % 4 == 0:
		damage += cannon_hit
		line = "主炮开火，合计造成 %d 伤害。" % damage
	enemy_hp = max(0, enemy_hp - damage)

	if enemy_hp <= 0:
		line += "\n第 %d 波目标清除。" % wave
		wave += 1
		if wave > int(selected_route["waves"]):
			battle_log.text = line
			_finish_battle(true)
			return
		enemy_max_hp = 46 + threat * 26 + (wave - 1) * 14
		enemy_hp = enemy_max_hp
	else:
		var incoming := 5 + threat * 4 + wave
		if wave % 2 == 0:
			tank_armor = max(0, tank_armor - incoming)
			line += "\n敌群撕咬履带，装甲 -%d。" % incoming
		else:
			hunter_hp = max(0, hunter_hp - max(2, incoming - 3))
			line += "\n流弹擦过掩体，猎人 HP -%d。" % max(2, incoming - 3)

	if hunter_hp <= 0 or tank_armor <= 0:
		battle_log.text = line
		_finish_battle(false)
		return
	battle_log.text = line
	_refresh_battle_ui()


func _finish_battle(victory: bool) -> void:
	auto_battle_running = false
	if victory:
		result_scrap = int(selected_route["reward"]) + tank_level * 5
		result_xp = int(selected_route["threat"]) * 20
		scrap += result_scrap
		rations += 2 + int(selected_route["threat"])
		hunter_level += 1 if result_xp >= 50 else 0
		result_text = "远征成功：%s 已清理。" % str(selected_route["name"])
	else:
		result_scrap = int(max(4, int(selected_route["reward"]) / 5))
		result_xp = 5
		scrap += result_scrap
		hunter_hp = 100
		tank_armor = int(max(40, tank_max_armor / 2))
		result_text = "远征中止：队伍带着残骸返回锈镇。"
	_switch_state(STATE_RESULT)


func _build_garage() -> void:
	_add_scene("town")
	_build_game_frame("车库升级", "消耗废金属强化角色与战车")
	_add_right_panel("当前战力", [
		"猎人 Lv.%d / HP %d" % [hunter_level, hunter_hp],
		"战车 Lv.%d / 装甲 %d/%d" % [tank_level, tank_armor, tank_max_armor],
		"主炮 Lv.%d" % cannon_level,
		"废金属：%d" % scrap,
	])

	var panel := _make_panel(Vector2(500, 280))
	panel.set_anchors_preset(Control.PRESET_TOP_LEFT)
	panel.offset_left = 26
	panel.offset_top = 86
	panel.offset_right = 526
	panel.offset_bottom = 366
	ui_layer.add_child(panel)
	var col := VBoxContainer.new()
	col.add_theme_constant_override("separation", 12)
	panel.add_child(col)
	col.add_child(_make_label("升级项目", 24, COL_GOLD))
	col.add_child(_make_button("强化战车装甲  费用 60", _upgrade_tank, Vector2(450, 48), 16))
	col.add_child(_make_button("校准主炮火控  费用 75", _upgrade_cannon, Vector2(450, 48), 16))
	col.add_child(_make_button("训练猎人等级  费用 45", _upgrade_hunter, Vector2(450, 48), 16))
	col.add_child(_make_button("补给燃料 +20  费用 30", _buy_fuel, Vector2(450, 48), 16))

	_add_bottom_bar([
		{"text": "返回城镇", "call": _switch_state.bind(STATE_TOWN)},
		{"text": "路线地图", "call": _switch_state.bind(STATE_ROUTE)},
	])


func _upgrade_tank() -> void:
	if scrap >= 60:
		scrap -= 60
		tank_level += 1
		tank_max_armor += 35
		tank_armor = tank_max_armor
	_switch_state(STATE_GARAGE)


func _upgrade_cannon() -> void:
	if scrap >= 75:
		scrap -= 75
		cannon_level += 1
	_switch_state(STATE_GARAGE)


func _upgrade_hunter() -> void:
	if scrap >= 45:
		scrap -= 45
		hunter_level += 1
		hunter_hp = 100
	_switch_state(STATE_GARAGE)


func _buy_fuel() -> void:
	if scrap >= 30:
		scrap -= 30
		fuel += 20
	_switch_state(STATE_GARAGE)


func _build_result() -> void:
	_add_scene("route")
	_build_game_frame("结算界面", "资源入库 → 升级或继续远征")
	var panel := _make_panel(Vector2(620, 360))
	panel.set_anchors_preset(Control.PRESET_CENTER)
	panel.offset_left = -310
	panel.offset_top = -180
	panel.offset_right = 310
	panel.offset_bottom = 180
	ui_layer.add_child(panel)
	var col := VBoxContainer.new()
	col.add_theme_constant_override("separation", 14)
	panel.add_child(col)
	col.add_child(_make_label(result_text, 26, COL_GOLD))
	col.add_child(_make_label("获得废金属 +%d\n获得经验 +%d\n当前资源：废金属 %d / 燃料 %d / 口粮 %d" % [result_scrap, result_xp, scrap, fuel, rations], 18, COL_TEXT))
	col.add_child(_make_label("下一步建议：装甲不足先回车库；燃料充足可以继续选择新路线。", 15, COL_CYAN))
	col.add_child(_make_button("回到城镇 Hub", _switch_state.bind(STATE_TOWN), Vector2(260, 48), 17))
	col.add_child(_make_button("打开车库升级", _switch_state.bind(STATE_GARAGE), Vector2(260, 48), 17))
	col.add_child(_make_button("继续选择路线", _switch_state.bind(STATE_ROUTE), Vector2(260, 48), 17))


func _add_scene(mode: String) -> void:
	var scene := WastelandScene.new(mode)
	scene.set_anchors_preset(Control.PRESET_FULL_RECT)
	scene_layer.add_child(scene)


func _build_game_frame(title: String, subtitle: String) -> void:
	var top := _make_panel(Vector2(0, 72))
	top.set_anchors_preset(Control.PRESET_TOP_WIDE)
	top.offset_left = 12
	top.offset_top = 10
	top.offset_right = -12
	top.offset_bottom = 82
	ui_layer.add_child(top)
	var root_row := HBoxContainer.new()
	root_row.add_theme_constant_override("separation", 8)
	top.add_child(root_row)

	var title_col := VBoxContainer.new()
	title_col.custom_minimum_size = Vector2(160, 50)
	title_col.add_theme_constant_override("separation", 2)
	root_row.add_child(title_col)
	title_col.add_child(_make_label(title, UIStyleGuide.FONT_SECTION, UIStyleGuide.GOLD))
	title_col.add_child(_make_label(subtitle, UIStyleGuide.FONT_TINY, UIStyleGuide.TEXT_MUTED))

	var bars := VBoxContainer.new()
	bars.custom_minimum_size = Vector2(226, 54)
	bars.add_theme_constant_override("separation", 2)
	root_row.add_child(bars)
	bars.add_child(_make_progress("HP", hunter_hp, 100, UIStyleGuide.HP, "hp"))
	bars.add_child(_make_progress("体力", 68, 100, UIStyleGuide.STAMINA, "energy"))

	var tank_bars := VBoxContainer.new()
	tank_bars.custom_minimum_size = Vector2(226, 54)
	tank_bars.add_theme_constant_override("separation", 2)
	root_row.add_child(tank_bars)
	tank_bars.add_child(_make_progress("战车", tank_armor, tank_max_armor, UIStyleGuide.ARMOR, "tank"))
	tank_bars.add_child(_make_progress("能量", 42 + cannon_level * 8, 100, UIStyleGuide.ENERGY, "energy"))

	var weapon_slot := _make_weapon_slot("主炮 Mk.%d" % cannon_level, "AUTO")
	root_row.add_child(weapon_slot)

	var resource_col := VBoxContainer.new()
	resource_col.custom_minimum_size = Vector2(180, 54)
	resource_col.add_theme_constant_override("separation", 3)
	root_row.add_child(resource_col)
	var res_row_a := HBoxContainer.new()
	res_row_a.add_theme_constant_override("separation", 6)
	resource_col.add_child(res_row_a)
	res_row_a.add_child(PixelIcon.new("coin", "%d" % scrap))
	res_row_a.add_child(PixelIcon.new("fuel", "%d" % fuel))
	var res_row_b := HBoxContainer.new()
	res_row_b.add_theme_constant_override("separation", 6)
	resource_col.add_child(res_row_b)
	res_row_b.add_child(PixelIcon.new("ammo", "AUTO"))
	res_row_b.add_child(PixelIcon.new("scrap", "Lv.%d" % tank_level))

	var status_panel := _make_status_icons()
	root_row.add_child(status_panel)


func _add_right_panel(title: String, lines: Array) -> void:
	var panel := _make_panel(Vector2(286, 0))
	panel.set_anchors_preset(Control.PRESET_RIGHT_WIDE)
	panel.offset_left = -306
	panel.offset_top = 96
	panel.offset_right = -14
	panel.offset_bottom = -90
	ui_layer.add_child(panel)
	var col := VBoxContainer.new()
	col.add_theme_constant_override("separation", 12)
	panel.add_child(col)
	col.add_child(_make_label(title, 18, COL_GOLD))
	for line in lines:
		var label := _make_label(str(line), 13, COL_TEXT)
		label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		col.add_child(label)


func _add_bottom_bar(buttons: Array) -> void:
	var bar := _make_panel(Vector2(0, 66))
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
		row.add_child(_make_button(str(item["text"]), callback, Vector2(166, 46), 15))
	for slot_name in ["cannon", "med", "mine", "repair", "radio"]:
		row.add_child(_make_inventory_slot(slot_name))
	var spacer := Control.new()
	spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(spacer)
	row.add_child(_make_label("核心循环：城镇 Hub → 路线 → 自动战斗 → 资源 → 升级 → 新区域", UIStyleGuide.FONT_BODY, UIStyleGuide.TEXT_MUTED))


func _refresh_battle_ui() -> void:
	if battle_status != null:
		battle_status.text = "第 %d/%d 波  ·  战斗 %.1fs" % [wave, int(selected_route["waves"]), battle_time]
	if hunter_hp_bar != null:
		hunter_hp_bar.set_values(hunter_hp, 100)
	if tank_hp_bar != null:
		tank_hp_bar.set_values(tank_armor, tank_max_armor)
	if enemy_hp_bar != null:
		enemy_hp_bar.set_values(enemy_hp, enemy_max_hp)


func _make_progress(label_text: String, value: int, max_value: int, color: Color, icon: String) -> Control:
	var bar := WASTELAND_PROGRESS_SCENE.instantiate() as Control
	bar.custom_minimum_size = Vector2(226, 26)
	if bar.has_method("configure"):
		bar.call("configure", label_text, value, max_value, color, icon)
	return bar


func _make_inventory_slot(kind: String) -> PanelContainer:
	var slot := PixelPanel.new(UIStyleGuide.SLOT_SIZE, "normal", true)
	slot.custom_minimum_size = UIStyleGuide.SLOT_SIZE
	var icon := PixelIcon.new(kind, "")
	icon.custom_minimum_size = UIStyleGuide.ICON_COMPACT_SIZE
	slot.add_child(icon)
	return slot


func _make_weapon_slot(name: String, ammo_text: String) -> PanelContainer:
	var slot := _make_panel(Vector2(150, 66))
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 8)
	slot.add_child(row)
	var icon := PixelIcon.new("weapon", "")
	icon.custom_minimum_size = UIStyleGuide.ICON_COMPACT_SIZE
	row.add_child(icon)
	var col := VBoxContainer.new()
	col.add_theme_constant_override("separation", 2)
	row.add_child(col)
	col.add_child(_make_label("当前武器", UIStyleGuide.FONT_TINY, UIStyleGuide.TEXT_MUTED))
	col.add_child(_make_label(name, UIStyleGuide.FONT_BODY, UIStyleGuide.GOLD))
	col.add_child(_make_label("弹药 %s" % ammo_text, UIStyleGuide.FONT_SMALL, UIStyleGuide.TEXT))
	return slot


func _make_status_icons() -> PanelContainer:
	var panel := _make_panel(Vector2(132, 66))
	var col := VBoxContainer.new()
	col.add_theme_constant_override("separation", 4)
	panel.add_child(col)
	col.add_child(_make_label("状态", UIStyleGuide.FONT_TINY, UIStyleGuide.TEXT_MUTED))
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 5)
	col.add_child(row)
	for kind in ["fuel", "ammo", "repair"]:
		var icon := PixelIcon.new(kind, "")
		icon.custom_minimum_size = Vector2(32, 28)
		row.add_child(icon)
	return panel


func _make_button(text: String, callback: Callable, min_size: Vector2, font_size: int) -> Button:
	var button := WASTELAND_BUTTON_SCENE.instantiate() as Button
	button.text = text
	button.custom_minimum_size = min_size
	button.focus_mode = Control.FOCUS_NONE
	button.theme = WASTELAND_THEME
	button.add_theme_font_override("font", system_font)
	button.add_theme_font_size_override("font_size", font_size)
	button.add_theme_color_override("font_color", UIStyleGuide.TEXT)
	button.add_theme_color_override("font_hover_color", UIStyleGuide.TEXT.lightened(0.08))
	button.add_theme_color_override("font_pressed_color", UIStyleGuide.GOLD)
	button.pressed.connect(callback)
	return button


func _make_panel(min_size: Vector2) -> PanelContainer:
	var panel := PIXEL_PANEL_SCENE.instantiate() as PanelContainer
	panel.custom_minimum_size = min_size
	panel.theme = WASTELAND_THEME
	return panel


func _make_label(text: String, font_size: int, color: Color) -> Label:
	var label := Label.new()
	label.text = text
	label.add_theme_font_override("font", system_font)
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", color)
	label.add_theme_color_override("font_outline_color", UIStyleGuide.BG_DARK)
	label.add_theme_constant_override("outline_size", 2)
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	return label


func _style(bg: Color, border: Color) -> StyleBoxFlat:
	return UIStyleGuide.panel_style(bg, border)


func _compact_style(bg: Color, border: Color) -> StyleBoxFlat:
	return UIStyleGuide.compact_panel_style(bg, border)


func _clear(node: Node) -> void:
	for child in node.get_children():
		child.queue_free()

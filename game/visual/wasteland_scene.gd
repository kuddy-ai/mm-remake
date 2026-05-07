# WastelandScene - programmatic side-scrolling scene renderer
# Renders pixel-art wasteland environment procedurally
# NOTE: Currently placeholder using code drawing, will be replaced with tilemaps

class_name WastelandScene

extends Control


# === Dependencies ===

const UIStyleGuide := preload("res://game/ui_style_guide.gd")
const RenderLayers := preload("res://game/visual/render_layers.gd")


# === Tile Constants ===

const TILE: float = 16.0
const PIX: float = 3.0


# === Scene Mode ===

var mode: String = "town"
var time: float = 0.0


func _init(scene_mode: String) -> void:
	mode = scene_mode
	mouse_filter = Control.MOUSE_FILTER_IGNORE


func _process(delta: float) -> void:
	time += delta
	queue_redraw()


func set_mode(new_mode: String) -> void:
	mode = new_mode
	queue_redraw()


func _draw() -> void:
	var w: float = size.x
	var h: float = size.y
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

	_draw_dust_particles(w, h)


# === Sky Rendering ===

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

	# Sun glow
	var sx: float = floorf(w * 0.62 / TILE) * TILE
	var sy: float = floorf(h * 0.24 / TILE) * TILE
	var sun_col := Color(0.90, 0.48, 0.18, 0.48)
	for y in range(4):
		for x in range(5):
			if abs(x - 2) + abs(y - 1) < 4:
				draw_rect(Rect2(sx + x * TILE, sy + y * TILE, TILE, TILE), sun_col)

	# Clouds
	for i in range(8):
		var px: float = fmod(i * 181.0, w)
		var py: float = floorf((h * 0.12 + fmod(i * 47.0, h * 0.25)) / TILE) * TILE
		draw_rect(Rect2(px, py, TILE * (2 + i % 4), TILE), Color(0.11, 0.08, 0.065, 0.28))


# === Background Layers ===

func _draw_background_layers(w: float, h: float) -> void:
	var gy: float = floorf(h * 0.62 / TILE) * TILE

	# Far mountains
	for i in range(14):
		var x: float = fmod(i * 137.0 - 40.0, w + 80.0) - 40.0
		var height: float = TILE * (4 + i % 6)
		var y: float = gy - height - TILE * (i % 3)
		var pts := PackedVector2Array([
			Vector2(x, gy),
			Vector2(x + TILE * 2, y + TILE * 2),
			Vector2(x + TILE * 4, y),
			Vector2(x + TILE * 7, gy),
		])
		draw_colored_polygon(pts, Color(0.105, 0.083, 0.065, 0.70))

	# Ruined structures
	for i in range(10):
		var x: float = fmod(i * 151.0 + 40.0, w)
		var y: float = gy - TILE * (5 + i % 5)
		draw_rect(Rect2(x, y, TILE * (2 + i % 3), TILE * (5 + i % 5)), Color(0.075, 0.066, 0.058, 0.72))
		draw_rect(Rect2(x + TILE * 0.5, y + TILE, TILE * 0.5, TILE * 0.5), Color(0.55, 0.34, 0.12, 0.18))
		draw_rect(Rect2(x + TILE * 1.4, y + TILE * 2.5, TILE * 0.5, TILE * 0.5), Color(0.10, 0.22, 0.20, 0.25))

	# Utility poles
	for i in range(6):
		var px: float = fmod(i * 223.0 + 80.0, w)
		var py: float = gy - TILE * (5 + i % 3)
		draw_rect(Rect2(px, py, TILE * 0.25, TILE * 6), Color(0.055, 0.048, 0.042, 0.84))
		draw_line(Vector2(px, py), Vector2(px + TILE * 5, py + TILE * 1.2), Color(0.045, 0.040, 0.035, 0.70), 2.0)


# === Terrain Rendering ===

func _draw_tile_terrain(w: float, h: float, gy: float) -> void:
	var cols: int = int(ceil(w / TILE)) + 1
	var rows: int = int(ceil((h - gy) / TILE)) + 2

	for x in range(cols):
		var crest: int = 0
		if x % 9 == 2:
			crest = -1
		elif x % 13 == 5:
			crest = 1

		for y in range(rows):
			var pos := Vector2(x * TILE, gy + (y + crest) * TILE)
			if pos.y < gy - TILE:
				continue

			var kind: String = "sand"
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
		var px: float = 2 + ((seed + i * 5) % 11)
		var py: float = 4 + ((seed * 3 + i * 7) % 9)
		draw_rect(Rect2(pos + Vector2(px, py), Vector2(2 + seed % 3, 2)), light.darkened(0.18))

	if kind == "metal":
		draw_rect(Rect2(pos + Vector2(3, 4), Vector2(10, 2)), Color(0.62, 0.23, 0.09))
		draw_rect(Rect2(pos + Vector2(10, 10), Vector2(3, 3)), Color(0.10, 0.34, 0.31))


# === Town Scene ===

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


# === Battle Scene ===

func _draw_battle(w: float, h: float, gy: float) -> void:
	_building(Vector2(floor(w * 0.56 / TILE) * TILE, gy - TILE * 7), Vector2(TILE * 15, TILE * 7), "FUEL", Color(0.17, 0.095, 0.070))
	_draw_oil_drums(Vector2(w * 0.72, gy - TILE * 2), 5)
	_draw_scrap_heap(Vector2(w * 0.50, gy - TILE * 3))
	_draw_tank(Vector2(w * 0.16 + floor(sin(time * 2.0) * 2.0), gy - TILE * 3), 3.2)
	_draw_hunter(Vector2(w * 0.31, gy - TILE * 4), 3.0, true)
	_draw_mech_dog(Vector2(w * 0.63 + floor(sin(time * 6.0) * 3.0), gy - TILE * 3), 3.0)
	_draw_mutant_bug(Vector2(w * 0.72, gy - TILE * 2.5), 2.4)
	_draw_scrap_drone(Vector2(w * 0.76, gy - TILE * 7 + floor(sin(time * 4.0) * 5.0)), 2.4)


# === Route Scene ===

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


# === Building Helper ===

func _building(pos: Vector2, s: Vector2, title: String, col: Color) -> void:
	draw_rect(Rect2(pos + Vector2(TILE * 0.5, s.y), Vector2(s.x, TILE * 0.5)), Color(0.02, 0.018, 0.014, 0.40))

	var cols: int = int(s.x / TILE)
	var rows: int = int(s.y / TILE)

	for x in range(cols):
		for y in range(rows):
			var kind: String = "wall"
			if x == 0 or x == cols - 1 or y == 0:
				kind = "metal"
			_draw_tile(pos + Vector2(x * TILE, y * TILE), kind, x + y * 17)

	# Windows and signs
	draw_rect(Rect2(pos + Vector2(TILE, TILE * 2), Vector2(TILE * 3, s.y - TILE * 2)), Color(0.045, 0.040, 0.035))
	draw_rect(Rect2(pos + Vector2(s.x - TILE * 4, TILE * 2), Vector2(TILE * 2, TILE * 1.5)), Color(0.055, 0.28, 0.25, 0.86))

	for i in range(3):
		draw_rect(Rect2(pos + Vector2(TILE * (2 + i * 3), TILE * 0.45), Vector2(TILE * 1.5, TILE * 0.35)), Color(0.72, 0.28, 0.10))

	var sign_width: float = minf(s.x - TILE * 2, title.length() * 12.0)
	draw_rect(Rect2(pos + Vector2(TILE, -TILE), Vector2(sign_width, TILE)), Color(0.68, 0.43, 0.16))
	draw_rect(Rect2(pos + Vector2(TILE + 4, -TILE + 5), Vector2(sign_width - 8, 4)), Color(0.08, 0.06, 0.045))


# === Entity Drawing Helpers ===

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
	_px(pos, 32, -5 + floor(sin(time * 5.0) * 1.0), 8, 4, Color(0.78, 0.16, 0.08), s)


func _draw_hunter(pos: Vector2, scale: float, walking: bool) -> void:
	var s := scale
	var frame: int = int(time * 5.0) % 2 if walking else 0
	var bob: float = float(frame)

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
	var bob: float = floorf(sin(time * 3.0))

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
	var frame: int = int(time * 7.0) % 2

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
	var bob: float = floorf(sin(time * 8.0))

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


# === Prop Helpers ===

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
		var kind: String = "metal" if i % 2 == 0 else "rock"
		_draw_tile(p, kind, i * 11)


func _draw_dust_particles(w: float, h: float) -> void:
	for i in range(80):
		var x: float = floorf(fmod(i * 61.0 + time * (18.0 + fmod(i, 5) * 6.0), w) / 2.0) * 2.0
		var y: float = floorf(fmod(i * 37.0 + sin(time + i) * 8.0, h * 0.80) / 2.0) * 2.0
		draw_rect(Rect2(x, y, 2, 2), Color(0.70, 0.50, 0.27, 0.18))
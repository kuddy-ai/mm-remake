extends ProgressBar

@export var label_text := "HP"
@export var icon_kind := "hp"
@export var fill_color := Color(0.46, 0.09, 0.055)

const UIStyleGuide := preload("res://game/ui_style_guide.gd")

func _ready() -> void:
	show_percentage = false
	custom_minimum_size = UIStyleGuide.METER_SIZE
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	queue_redraw()


func configure(new_label: String, current: int, maximum: int, color: Color, icon: String) -> void:
	label_text = new_label
	icon_kind = icon
	fill_color = color
	set_values(current, maximum)


func set_values(current: int, maximum: int) -> void:
	min_value = 0
	max_value = max(1, maximum)
	value = clamp(current, 0, int(max_value))
	queue_redraw()


func _draw() -> void:
	var icon_w := 24.0
	_draw_icon(Vector2(0, 3), icon_kind)
	var bar := Rect2(icon_w + 6, 4, maxf(42.0, size.x - icon_w - 8), size.y - 8)
	_draw_slot(bar)
	var fill_w := floorf((bar.size.x - 8.0) * clampf(float(value) / float(max_value), 0.0, 1.0))
	if fill_w > 0.0:
		var fill := Rect2(bar.position + Vector2(4, 4), Vector2(fill_w, bar.size.y - 8))
		draw_rect(fill, fill_color.darkened(0.30))
		draw_rect(Rect2(fill.position, Vector2(fill.size.x, 2)), fill_color.lightened(0.12))
		draw_rect(Rect2(fill.position + Vector2(0, fill.size.y - 3), Vector2(fill.size.x, 2)), fill_color.darkened(0.46))
		for x in range(int(fill_w / 8.0)):
			var tick_col := fill_color.darkened(0.48 if x % 2 == 0 else 0.22)
			draw_rect(Rect2(fill.position + Vector2(2 + x * 8, fill.size.y - 4), Vector2(3, 2)), tick_col)
	var text := "%s  %d/%d" % [label_text, int(value), int(max_value)]
	draw_string(ThemeDB.fallback_font, bar.position + Vector2(8, 16), text, HORIZONTAL_ALIGNMENT_LEFT, bar.size.x - 16, UIStyleGuide.FONT_SMALL, UIStyleGuide.TEXT)


func _draw_slot(rect: Rect2) -> void:
	draw_rect(rect, UIStyleGuide.BG_DARK)
	draw_rect(Rect2(rect.position + Vector2(2, 2), rect.size - Vector2(4, 4)), UIStyleGuide.BORDER_DARK)
	draw_rect(Rect2(rect.position + Vector2(4, 4), rect.size - Vector2(8, 8)), UIStyleGuide.PANEL_INSET)
	draw_rect(Rect2(rect.position + Vector2(4, 4), Vector2(rect.size.x - 8, 1)), UIStyleGuide.BORDER.lightened(0.18))
	draw_rect(Rect2(rect.position + Vector2(4, rect.size.y - 6), Vector2(rect.size.x - 8, 2)), UIStyleGuide.BORDER_DARK)
	for i in range(4):
		var x := rect.position.x + 10 + i * maxf(18.0, rect.size.x / 5.0)
		if x < rect.position.x + rect.size.x - 14:
			draw_rect(Rect2(x, rect.position.y + rect.size.y - 8, 4, 1), UIStyleGuide.WARNING.darkened(0.32))


func _draw_icon(pos: Vector2, kind: String) -> void:
	draw_rect(Rect2(pos, Vector2(22, 22)), UIStyleGuide.BG_DARK)
	draw_rect(Rect2(pos + Vector2(2, 2), Vector2(18, 18)), UIStyleGuide.PANEL_INSET.lightened(0.06))
	if kind == "hp":
		draw_rect(Rect2(pos + Vector2(7, 4), Vector2(8, 14)), UIStyleGuide.HP.lightened(0.10))
		draw_rect(Rect2(pos + Vector2(4, 7), Vector2(14, 8)), UIStyleGuide.HP.lightened(0.10))
	elif kind == "energy":
		draw_rect(Rect2(pos + Vector2(9, 3), Vector2(6, 7)), UIStyleGuide.STAMINA.darkened(0.05))
		draw_rect(Rect2(pos + Vector2(6, 9), Vector2(6, 10)), UIStyleGuide.STAMINA.lightened(0.16))
		draw_rect(Rect2(pos + Vector2(11, 9), Vector2(5, 5)), UIStyleGuide.BORDER_DARK)
	elif kind == "tank":
		draw_rect(Rect2(pos + Vector2(4, 9), Vector2(13, 7)), UIStyleGuide.SCRAP)
		draw_rect(Rect2(pos + Vector2(7, 6), Vector2(7, 4)), UIStyleGuide.SCRAP.lightened(0.18))
		draw_rect(Rect2(pos + Vector2(14, 7), Vector2(6, 2)), UIStyleGuide.SCRAP.darkened(0.25))
	else:
		draw_rect(Rect2(pos + Vector2(5, 5), Vector2(12, 12)), UIStyleGuide.ENERGY.darkened(0.10))

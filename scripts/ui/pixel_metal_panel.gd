extends PanelContainer

@export var frame_state := "normal"
@export var compact := false

const UIStyleGuide := preload("res://game/ui_style_guide.gd")

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_PASS
	add_theme_stylebox_override("panel", UIStyleGuide.compact_panel_style() if compact else UIStyleGuide.panel_style())
	queue_redraw()


func _draw() -> void:
	var rect := Rect2(Vector2.ZERO, size)
	if rect.size.x <= 4.0 or rect.size.y <= 4.0:
		return
	var border := UIStyleGuide.BORDER
	var bg := UIStyleGuide.PANEL_BG
	if frame_state == "warning":
		border = UIStyleGuide.WARNING
	elif frame_state == "danger":
		border = UIStyleGuide.DANGER
	elif frame_state == "selected":
		border = UIStyleGuide.AVAILABLE
	elif frame_state == "disabled":
		border = UIStyleGuide.BORDER_DARK
		bg = UIStyleGuide.PANEL_INSET.darkened(0.22)

	draw_rect(rect, UIStyleGuide.BG_DARK)
	draw_rect(Rect2(rect.position + Vector2(2, 2), rect.size - Vector2(4, 4)), UIStyleGuide.BORDER_DARK)
	draw_rect(Rect2(rect.position + Vector2(4, 4), rect.size - Vector2(8, 8)), border.darkened(0.28))
	draw_rect(Rect2(rect.position + Vector2(6, 6), rect.size - Vector2(12, 12)), bg)
	draw_rect(Rect2(rect.position + Vector2(8, 8), rect.size - Vector2(16, 16)), UIStyleGuide.PANEL_INSET.darkened(0.03))
	_draw_inner_lines(rect, border)
	_draw_rivets(rect, border)
	_draw_wear(rect)


func _draw_inner_lines(rect: Rect2, border: Color) -> void:
	var inner := Rect2(rect.position + Vector2(7, 7), rect.size - Vector2(14, 14))
	draw_rect(Rect2(inner.position, Vector2(inner.size.x, 1)), border.lightened(0.12))
	draw_rect(Rect2(inner.position + Vector2(0, inner.size.y - 2), Vector2(inner.size.x, 2)), UIStyleGuide.BORDER_DARK)
	draw_rect(Rect2(inner.position, Vector2(1, inner.size.y)), UIStyleGuide.BORDER_DARK.lightened(0.10))
	draw_rect(Rect2(inner.position + Vector2(inner.size.x - 2, 0), Vector2(2, inner.size.y)), UIStyleGuide.BORDER_DARK.darkened(0.08))


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


func _draw_wear(rect: Rect2) -> void:
	var count := int(clampf(rect.size.x / 74.0, 2.0, 9.0))
	for i in range(count):
		var x := 16.0 + fmod(i * 47.0, maxf(20.0, rect.size.x - 36.0))
		var y := 14.0 + fmod(i * 31.0, maxf(18.0, rect.size.y - 30.0))
		var w := 7.0 + fmod(i * 5.0, 17.0)
		draw_rect(Rect2(rect.position + Vector2(x, y), Vector2(w, 1)), UIStyleGuide.TEXT_MUTED.darkened(0.22))
		if i % 2 == 0:
			draw_rect(Rect2(rect.position + Vector2(x + 3, y + 2), Vector2(w * 0.45, 1)), UIStyleGuide.BORDER_DARK)
	for i in range(5):
		var x := 10.0 + fmod(i * 61.0, maxf(16.0, rect.size.x - 24.0))
		var y := 5.0 if i % 2 == 0 else rect.size.y - 9.0
		draw_rect(Rect2(rect.position + Vector2(x, y), Vector2(7 + i % 3, 2)), UIStyleGuide.WARNING.darkened(0.28))

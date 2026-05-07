extends PanelContainer

@export var selected := false
@export var disabled_state := false

const UIStyleGuide := preload("res://game/ui_style_guide.gd")

func _ready() -> void:
	custom_minimum_size = UIStyleGuide.SLOT_SIZE
	add_theme_stylebox_override("panel", UIStyleGuide.compact_panel_style())
	queue_redraw()


func _draw() -> void:
	var border := UIStyleGuide.BORDER_DARK if disabled_state else (UIStyleGuide.WARNING if selected else UIStyleGuide.BORDER)
	draw_rect(Rect2(Vector2.ZERO, size), UIStyleGuide.BG_DARK)
	draw_rect(Rect2(2, 2, size.x - 4, size.y - 4), border.darkened(0.20))
	draw_rect(Rect2(5, 5, size.x - 10, size.y - 10), UIStyleGuide.PANEL_INSET)
	draw_rect(Rect2(7, 7, size.x - 14, 1), border.lightened(0.12))
	draw_rect(Rect2(size.x - 10, 7, 3, 3), border.darkened(0.08))
	draw_rect(Rect2(7, size.y - 10, 3, 3), border.darkened(0.08))

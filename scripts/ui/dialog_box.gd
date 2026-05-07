extends PanelContainer

const UIStyleGuide := preload("res://game/ui_style_guide.gd")

func _ready() -> void:
	add_theme_stylebox_override("panel", UIStyleGuide.panel_style())
	queue_redraw()


func _draw() -> void:
	draw_rect(Rect2(Vector2.ZERO, size), UIStyleGuide.BG_DARK)
	draw_rect(Rect2(4, 4, size.x - 8, size.y - 8), UIStyleGuide.BORDER_DARK)
	draw_rect(Rect2(7, 7, size.x - 14, size.y - 14), UIStyleGuide.PANEL_INSET)
	draw_rect(Rect2(12, 10, minf(170.0, size.x - 24.0), 22), UIStyleGuide.BORDER.darkened(0.34))

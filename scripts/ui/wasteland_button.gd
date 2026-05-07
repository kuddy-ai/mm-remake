extends Button

const UIStyleGuide := preload("res://game/ui_style_guide.gd")

func _ready() -> void:
	focus_mode = Control.FOCUS_NONE
	add_theme_stylebox_override("normal", UIStyleGuide.button_style("normal"))
	add_theme_stylebox_override("hover", UIStyleGuide.button_style("hover"))
	add_theme_stylebox_override("pressed", UIStyleGuide.button_style("pressed"))
	add_theme_stylebox_override("disabled", UIStyleGuide.panel_style(UIStyleGuide.PANEL_INSET.darkened(0.16), UIStyleGuide.BORDER_DARK))
	add_theme_color_override("font_color", UIStyleGuide.TEXT)
	add_theme_color_override("font_hover_color", UIStyleGuide.TEXT.lightened(0.08))
	add_theme_color_override("font_pressed_color", UIStyleGuide.GOLD)
	add_theme_color_override("font_disabled_color", UIStyleGuide.TEXT_MUTED.darkened(0.18))


func _draw() -> void:
	var rect := Rect2(Vector2.ZERO, size)
	if rect.size.x <= 10.0 or rect.size.y <= 10.0:
		return
	var edge := UIStyleGuide.BORDER
	if button_pressed:
		edge = UIStyleGuide.WARNING
	elif is_hovered():
		edge = UIStyleGuide.CYAN.darkened(0.18)
	elif disabled:
		edge = UIStyleGuide.BORDER_DARK
	draw_rect(Rect2(7, 5, size.x - 14, 1), edge.darkened(0.05))
	draw_rect(Rect2(7, size.y - 7, size.x - 14, 1), UIStyleGuide.BORDER_DARK)
	for p in [Vector2(7, 7), Vector2(size.x - 10, 7), Vector2(7, size.y - 10), Vector2(size.x - 10, size.y - 10)]:
		draw_rect(Rect2(p, Vector2(3, 3)), edge.darkened(0.12))
	for i in range(int(clampf(size.x / 80.0, 1.0, 4.0))):
		var x := 14.0 + fmod(i * 53.0, maxf(12.0, size.x - 30.0))
		draw_rect(Rect2(x, size.y * 0.35 + fmod(i * 7.0, 10.0), 10 + i * 2, 1), UIStyleGuide.TEXT_MUTED.darkened(0.32))

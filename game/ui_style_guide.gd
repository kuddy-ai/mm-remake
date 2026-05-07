class_name UIStyleGuide
extends RefCounted

const BG_DARK := Color(0.012, 0.011, 0.010, 0.98)
const PANEL_BG := Color(0.026, 0.028, 0.026, 0.96)
const PANEL_INSET := Color(0.018, 0.019, 0.018, 0.98)
const BORDER := Color(0.32, 0.245, 0.145, 0.96)
const BORDER_DARK := Color(0.10, 0.075, 0.050, 0.98)
const TEXT := Color(0.72, 0.66, 0.52)
const TEXT_MUTED := Color(0.43, 0.38, 0.30)
const GOLD := Color(0.72, 0.50, 0.22)
const CYAN := Color(0.20, 0.50, 0.48)
const DANGER := Color(0.56, 0.12, 0.075)
const HP := Color(0.46, 0.09, 0.055)
const STAMINA := Color(0.55, 0.39, 0.14)
const ENERGY := Color(0.18, 0.36, 0.39)
const ARMOR := Color(0.34, 0.38, 0.32)
const SCRAP := Color(0.36, 0.34, 0.28)
const WARNING := Color(0.62, 0.30, 0.10)
const AVAILABLE := Color(0.26, 0.42, 0.22)

const FONT_TITLE := 20
const FONT_SECTION := 16
const FONT_BODY := 13
const FONT_SMALL := 11
const FONT_TINY := 10

const BORDER_WIDTH := 2
const PANEL_RADIUS := 0
const PANEL_SHADOW := 4
const PANEL_SHADOW_OFFSET := Vector2(2, 2)
const METER_SIZE := Vector2(250, 28)
const ICON_FRAME_SIZE := Vector2(84, 28)
const ICON_COMPACT_SIZE := Vector2(34, 30)
const SLOT_SIZE := Vector2(44, 44)

static func panel_style(bg: Color = PANEL_BG, border: Color = BORDER) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = bg
	style.border_color = border
	style.set_border_width_all(BORDER_WIDTH)
	style.set_corner_radius_all(PANEL_RADIUS)
	style.anti_aliasing = false
	style.content_margin_left = 14
	style.content_margin_right = 14
	style.content_margin_top = 10
	style.content_margin_bottom = 10
	style.shadow_color = Color(0, 0, 0, 0.62)
	style.shadow_size = PANEL_SHADOW
	style.shadow_offset = PANEL_SHADOW_OFFSET
	return style


static func compact_panel_style(bg: Color = PANEL_INSET, border: Color = BORDER) -> StyleBoxFlat:
	var style := panel_style(bg, border)
	style.content_margin_left = 4
	style.content_margin_right = 4
	style.content_margin_top = 4
	style.content_margin_bottom = 4
	return style


static func button_style(state: String) -> StyleBoxFlat:
	if state == "hover":
		return panel_style(Color(0.046, 0.070, 0.060, 0.98), CYAN)
	if state == "pressed":
		return panel_style(Color(0.085, 0.060, 0.040, 0.98), WARNING)
	return panel_style(Color(0.030, 0.033, 0.030, 0.98), BORDER)

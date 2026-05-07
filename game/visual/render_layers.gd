# Render layer definitions for visual ordering
# Provides layer indices for proper rendering

class_name RenderLayers

extends RefCounted


# === Layer Indices ===
# Higher values render on top

const BACKGROUND: int = 0
const TERRAIN: int = 10
const TERRAIN_DETAIL: int = 15
const PROPS_BACK: int = 20
const CHARACTERS: int = 30
const VEHICLES: int = 35
const PROPS_FRONT: int = 40
const EFFECTS: int = 50
const LIGHTING: int = 60
const UI_HUD: int = 100
const UI_MODAL: int = 110
const DEBUG: int = 200


# === Layer Names ===

const LAYER_NAMES: Dictionary = {
	BACKGROUND: "background",
	TERRAIN: "terrain",
	TERRAIN_DETAIL: "terrain_detail",
	PROPS_BACK: "props_back",
	CHARACTERS: "characters",
	VEHICLES: "vehicles",
	PROPS_FRONT: "props_front",
	EFFECTS: "effects",
	LIGHTING: "lighting",
	UI_HUD: "ui_hud",
	UI_MODAL: "ui_modal",
	DEBUG: "debug",
}


static func get_layer_name(index: int) -> String:
	return LAYER_NAMES.get(index, "unknown")


static func is_ui_layer(index: int) -> bool:
	return index >= UI_HUD
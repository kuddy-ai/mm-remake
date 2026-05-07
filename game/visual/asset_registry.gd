# Asset registry - unified resource key to path mapping
# Central point for all asset path references

class_name AssetRegistry

extends RefCounted


# === Audio Resources ===

const BGM_OPENING: String = "res://assets/audio/bgm/001_opening_theme.ogg"
const BGM_WASTELAND: String = "res://assets/audio/bgm/002_wasteland_field_loop.ogg"
const BGM_BATTLE: String = "res://assets/audio/bgm/003_battle_normal_loop.ogg"
const BGM_BOSS: String = "res://assets/audio/bgm/004_boss_battle_loop.ogg"


# === UI Themes ===

const THEME_WASTELAND: String = "res://themes/wasteland_ui_theme.tres"


# === UI Scenes ===

const UI_PANEL_METAL: String = "res://scenes/ui/PixelMetalPanel.tscn"
const UI_BUTTON_WASTELAND: String = "res://scenes/ui/WastelandButton.tscn"
const UI_PROGRESS_BAR: String = "res://scenes/ui/WastelandProgressBar.tscn"
const UI_INVENTORY_SLOT: String = "res://scenes/ui/InventorySlot.tscn"
const UI_DIALOG_BOX: String = "res://scenes/ui/DialogBox.tscn"
const UI_BATTLE_COMMAND: String = "res://scenes/ui/BattleCommandButton.tscn"


# === Placeholder Sprites (to be replaced) ===
# These paths are placeholders for future sprite assets

const SPRITE_PLAYER_IDLE: String = "res://assets/sprites/player/hunter_idle.png"
const SPRITE_PLAYER_WALK: String = "res://assets/sprites/player/hunter_walk.png"
const SPRITE_TANK_IDLE: String = "res://assets/sprites/vehicles/tank_idle.png"
const SPRITE_TANK_MOVE: String = "res://assets/sprites/vehicles/tank_move.png"

const SPRITE_ENEMY_DOG: String = "res://assets/sprites/enemies/mech_dog.png"
const SPRITE_ENEMY_BUG: String = "res://assets/sprites/enemies/mutant_bug.png"
const SPRITE_ENEMY_DRONE: String = "res://assets/sprites/enemies/scrap_drone.png"


# === Placeholder Tilesets (to be replaced) ===

const TILESET_WASTELAND: String = "res://assets/tilesets/wasteland/wasteland_base.tres"
const TILESET_TOWN: String = "res://assets/tilesets/town/town_base.tres"
const TILESET_RUINS: String = "res://assets/tilesets/ruins/ruins_base.tres"


# === Placeholder Backgrounds (to be replaced) ===

const BG_WASTELAND_SKY: String = "res://assets/backgrounds/wasteland/sky_gradient.png"
const BG_TOWN_BACK: String = "res://assets/backgrounds/wasteland/town_back.png"
const BG_BATTLE_FIELD: String = "res://assets/backgrounds/battle/field_back.png"


# === Helper Methods ===

static func load_bgm(key: String) -> AudioStream:
	if not FileAccess.file_exists(key):
		return null
	return load(key)


static func load_scene(key: String) -> PackedScene:
	if not FileAccess.file_exists(key):
		return null
	return load(key)


static func load_texture(key: String) -> Texture2D:
	if not FileAccess.file_exists(key):
		return null
	return load(key)


static func exists(key: String) -> bool:
	return FileAccess.file_exists(key)


static func get_available_bgm() -> Array[String]:
	var result: Array[String] = []
	for path in [BGM_OPENING, BGM_WASTELAND, BGM_BATTLE, BGM_BOSS]:
		if exists(path):
			result.append(path)
	return result
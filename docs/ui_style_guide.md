# Wasteland Hunter UI Style Guide

Source of truth: `docs/concept-art/wasteland_hunter_design_images`.

## Design Images Reviewed

Reviewed 32 reference files:

- `a_large_compilation_infographic_image_pixel_art_g.png`
- `bounty_board_sandworm_alpha_dossier.png`
- `desolate_battlefield_in_a_post_apocalypse.png`
- `desolate_highway_to_ironridge_town.png`
- `desolate_wasteland_strategy_map_screen.png`
- `dustwalk_settlement_in_a_desolate_wasteland.png`
- `epic_boss_fight_in_a_wasteland.png`
- `facility_b_12_boss_encounter_battle.png`
- `gritty_post_apocalyptic_medical_bay_treatment.png`
- `post_apocalyptic_character_equipment_ui.png`
- `post_apocalyptic_scrap_shop_interface.png`
- `post_apocalyptic_settlement_game_hub_ui.png`
- `radio_tower_dispatch_interface.png`
- `rust_and_neon_of_novice_town.png`
- `rustbucket_tavern_bounty_hunter_interface.png`
- `rustwalk_a_wasteland_settlement_at_dusk.png`
- `rustwalk_town_hub_at_sunset.png`
- `rustwalker_post_apocalyptic_tank_design.png`
- `standoff_in_a_ruined_wasteland.png`
- `steampunk_garage_upgrade_interface.png`
- `survivor_of_the_wasteland_mercenary_concept_art.png`
- `tactical_squad_setup_in_apocalyptic_bunker.png`
- `tank_hunter_rpg_concept_moodboard.png`
- `tank_repair_bay_in_a_wasteland_garage.png`
- `victory_in_the_wasteland_battle.png`
- `wasteland_battle_with_auto_fight_interface.png`
- `wasteland_hunter_character_and_concept_sheet.png`
- `wasteland_hunter_title_screen.png`
- `wasteland_road_trip_through_ruins.png`
- `wasteland_tank_battle_overview.png`
- `wasteland_wanderer_in_a_ruined_world.png`
- `wasteland_warrior_in_a_crumbled_world.png`

## UI Visual Audit

Current UI gaps against the references:

- The existing HUD is too tall and widget-like. Reference HUDs use compact segmented metal resource bars and grounded bottom status cards.
- Existing panels use pixel scratches and rivets, but the structure is still too clean and broad. References use thin inset separators, double metal borders, rusty corner bolts, and darker inner fields.
- Existing buttons still rely on normal Godot button behavior with bright hover accents. Reference buttons look like recessed tank console switches, with muted green selected states and only small edge highlights.
- Existing icons are simplified colored symbols and can read as toy-like when placed in bright slots. Reference icons are hard-edged, dull metal, ammo, coins, gears, crates, shield, and tactical symbols.
- Current progress bars are improved but still too flat. Reference meters are black recessed channels with an outer mechanical frame, bevel strips, numeric overlay, and damaged fill ticks.
- Existing palette has some clean cyan and bright gold accents. References mostly use black iron, rust brown, dusty tan text, military green selected states, dull amber warnings, dark red HP, and muted cyan only for tactical highlights.
- The UI root is currently a `Control`; reference-aligned HUD work should sit in a `CanvasLayer` with scene content behind it.
- Theme/style resources and reusable Godot UI scenes are missing, so visual rules are still partly scattered in code.

## UI Keywords

- Wasteland mechanical pixel UI
- Tank dashboard
- Old metal control console
- Repair station control panel
- Military equipment crate
- Rusted iron plate
- Rivets and corner bolts
- Scratches, oil grime, worn edges
- Dark inner wells and inset separators
- Low-saturation wasteland palette
- Hard rectangular pixel structure

## Forbidden Style

- Toy-like UI
- Candy colors
- Plastic buttons
- Chibi or cute icons
- Rounded capsule controls
- High-saturation blue, green, purple, or pink
- Modern web or mobile-app styling
- Flat Material Design
- Glassmorphism
- Cyber neon
- Large clean solid-color blocks

## Palette

Use these values as the shared UI palette:

- `bg_dark`: `#050403` for near-black iron gaps and outer shadows.
- `panel_bg`: `#11110f` for main dark metal plates.
- `panel_inset`: `#080908` for recessed inner wells.
- `border`: `#5b3f22` for rusty brass/iron outlines.
- `border_dark`: `#1d140c` for outer dark bevels and separators.
- `text`: `#b9a982` for readable dusty tan labels.
- `text_muted`: `#70634c` for secondary labels.
- `gold`: `#b98634` for resource values and headings.
- `warning`: `#9d4d1a` for small warning accents.
- `danger`: `#8f1f13` for HP/danger.
- `available`: `#456b38` for selected/available console states.
- `energy`: `#2e5c63` for muted tactical/energy bars.
- `armor`: `#555f50` for vehicle durability.
- `scrap`: `#5c5747` for metal scrap and icon fills.

Do not use large areas of pure white, pure black, bright cyan, bright green, pink, purple, or candy yellow.

## HUD Rules

- HUD must preserve the playfield. Use a compact top resource strip and grounded bottom/side console cards.
- Resource displays are segmented metal capsules with hard rectangular corners, small pixel icons, value text, and optional small delta text.
- Player/tank status cards follow the reference: portrait/icon area on the left, level/name labels, recessed HP/armor bars, and small stat rows.
- Current weapon/ammo display is a metal slot, not a floating text badge.
- Status icons live in square metal wells, using muted hard-edged symbols.
- In battle, route/wave indicators may sit near the top center as narrow metal strips.

## Panel Rules

- Panels use double borders: dark outer edge, rusty metal line, inset inner field.
- Corners must have small rivets or bolts.
- Large panels need subtle scratches, rust streaks, and seam lines drawn procedurally or through reusable pixel resources.
- Corners are square or nearly square. Rounded cartoon panels are not allowed.
- Padding must keep text clear but compact, matching the dense control-panel look in the references.

## Button Rules

- Buttons look like old tank console keys or metal switches.
- Normal state is dark metal.
- Hover state uses a small edge highlight only.
- Pressed state shifts darker/downward and may use dull amber.
- Selected state uses military green with rusty border.
- Disabled state is low-contrast grey metal.
- Do not use bright fills, gradients, pill shapes, or plastic-like shine.

## Progress Bar Rules

- Bars are mechanical slots with outer frame, black inner track, fill bevel, and small damaged ticks.
- HP uses dark red/rust red.
- Stamina/fuel can use dusty amber or military green.
- Energy uses muted grey-blue/teal.
- Vehicle durability uses metal grey/olive or dull orange warning when low.
- Values must remain readable inside or beside the bar.

## Inventory Slot Rules

- Slots look like military tool crate cells or old metal warehouse bins.
- Use square wells, heavy dark bevels, and muted metal interiors.
- Hover and selected states are border changes, not bright fill changes.
- Selected state may use dull yellow warning trim or muted green scan trim.

## Dialog Rules

- Dialog boxes resemble radio/terminal panels or riveted metal nameplates.
- Speaker names sit in a small top metal label.
- Body text is dusty tan on dark inset metal, with enough padding for Chinese line breaks.
- Continue prompts are small mechanical indicators, not cute arrows.

## Battle UI Rules

- Battle commands use the same old control-console button style as the HUD.
- Enemy bars and target info resemble tactical target cards: dark field, red HP slot, muted armor bar, small warning icon.
- Battle logs look like old radio/terminal output, not a web card.

## Font Rules

- Use a readable system CJK font until a pixel CJK font is provided.
- Title: 20-24 px.
- Section/head labels: 15-18 px.
- Body: 13-15 px.
- Small numeric/meta text: 10-12 px.
- Text color should be dusty tan. Avoid pure white.
- Outlines may be near-black iron, 1-2 px only.

## Icon Rules

- Icons are 16-24 px hard-edged pixel symbols inside 28-44 px metal wells.
- Use wasteland military symbols: ammo shell, gear, coin/metal token, fuel can, med kit, shield, tank tread, radio, crate.
- Icon palettes should use dull metal, rust, dusty tan, dark red, muted teal, and military green.
- Avoid cute faces, round toy gears, glossy app icons, and high-saturation fills.

## Godot Implementation

- HUD root uses `CanvasLayer`.
- UI is built from `Control` nodes with `PanelContainer`, `MarginContainer`, `HBoxContainer`, `VBoxContainer`, and `GridContainer`.
- Shared visuals live in `res://themes/wasteland_ui_theme.tres` and reusable scenes in `res://scenes/ui/`.
- Use `StyleBoxFlat` for generated metal surfaces. Use `NinePatchRect/NinePatchTexture` later only when hand-authored pixel border resources exist.
- Do not flatten the UI into one image.
- Use `TextureRect` or custom-drawn `Control` icons for icons; keep nearest-neighbor filtering.
- Use reusable components for metal panels, buttons, progress bars, inventory slots, dialog boxes, and battle command buttons.
- Project texture filtering must stay nearest: `textures/canvas_textures/default_texture_filter=0`.

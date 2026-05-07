# Wasteland Hunter UI Style Guide

## Design Reference

Source of truth: `docs/concept-art/wasteland_hunter_design_images`.

Reviewed 32 reference files including title screens, battle layouts, settlement hubs, garage interfaces, tavern systems, and environment scenes. See `docs/concept-art/wasteland_hunter_design_images/README.md` for complete list.

## Visual Audit Baseline

The reference images use heavy dark metal panels, rusty brass trim, worn text, rivets, scratches, oily seams, low-saturation status colors, and military control-console buttons. UI must feel like vehicle dashboards, workshop plates, old terminals, ammo crates, and field equipment.

**Corrective direction from prototype audit:**
- Existing HUD is too tall and widget-like. Reference HUDs use compact segmented metal resource bars.
- Panels use pixel scratches and rivets, but structure is too clean. References use thin inset separators, double metal borders, rusty corner bolts, darker inner fields.
- Buttons rely on normal Godot behavior with bright hover accents. Reference buttons look like recessed tank console switches with muted green selected states.
- Icons are simplified colored symbols and read as toy-like. Reference icons are hard-edged, dull metal, ammo, coins, gears, crates, shield, tactical symbols.
- Progress bars are too flat. Reference meters are black recessed channels with outer mechanical frame, bevel strips, numeric overlay, damaged fill ticks.
- Palette has clean cyan and bright gold accents. References use black iron, rust brown, dusty tan text, military green selected states, dull amber warnings, dark red HP, muted cyan for tactical highlights.

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

## Palette

Use these values as the shared UI palette (defined in `game/ui_style_guide.gd`):

| Constant | Hex Value | Usage |
|----------|-----------|-------|
| `BG_DARK` | `#050403` | Near-black iron gaps and outer shadows |
| `PANEL_BG` | `#11110f` | Main dark metal plates |
| `PANEL_INSET` | `#080908` | Recessed inner wells |
| `BORDER` | `#5b3f22` | Rusty brass/iron outlines |
| `BORDER_DARK` | `#1d140c` | Outer dark bevels and separators |
| `TEXT` | `#b9a982` | Readable dusty tan labels |
| `TEXT_MUTED` | `#70634c` | Secondary labels |
| `GOLD` | `#b98634` | Resource values and headings |
| `WARNING` | `#9d4d1a` | Small warning accents |
| `DANGER` | `#8f1f13` | HP/danger |
| `AVAILABLE` | `#456b38` | Selected/available console states |
| `ENERGY` | `#2e5c63` | Muted tactical/energy bars |
| `ARMOR` | `#555f50` | Vehicle durability |
| `SCRAP` | `#5c5747` | Metal scrap and icon fills |
| `CYAN` | - | Active system highlights (use muted) |
| `STAMINA` | - | Stamina/energy bars |

Do not use large areas of pure white, pure black, bright cyan, bright green, pink, purple, or candy yellow.

## Font Sizes

| Constant | Size | Usage |
|----------|------|-------|
| `FONT_TITLE` | 20 px | Major HUD title only |
| `FONT_SECTION` | 16 px | Panel headers and battle phase text |
| `FONT_BODY` | 13 px | Standard values and labels |
| `FONT_SMALL` | 11 px | Secondary metadata |
| `FONT_TINY` | 10 px | Status captions |

Use a readable system CJK font until a pixel CJK font is provided. Text color should be dusty tan. Avoid pure white. Outlines may be near-black iron, 1-2 px only.

## HUD Rules

- HUD must preserve the playfield. Use compact top resource strip and grounded bottom/side console cards.
- HUD root uses `CanvasLayer`.
- Resource displays are segmented metal capsules with hard rectangular corners, small pixel icons, value text, optional small delta text.
- Player/tank status cards: portrait/icon area on left, level/name labels, recessed HP/armor bars, small stat rows.
- Current weapon/ammo display is a metal slot, not floating text badge.
- Status icons live in square metal wells, using muted hard-edged symbols.
- In battle, route/wave indicators may sit near top center as narrow metal strips.

## Panel Rules

- Panels use double borders: dark outer edge, rusty metal line, inset inner field.
- Border width is 2 px.
- Corners must have small rivets or bolts.
- Corners are square or nearly square. Rounded cartoon panels are not allowed.
- Large panels need subtle scratches, rust streaks, seam lines drawn procedurally or through reusable pixel resources.
- Padding must keep text clear but compact, matching dense control-panel look.
- No gradients, blur, transparency-heavy glass, rounded cards, or antialiasing-heavy surfaces.

## Button Rules

- Buttons look like old tank console keys or metal switches.
- Normal: dark metal fill, rusty brass border, sand text.
- Hover: green-cyan active fill/border, small edge highlight only, cyan text.
- Pressed: warm rust fill/border, shifts darker/downward, dull amber, gold text.
- Selected: military green with rusty border.
- Disabled: low-contrast grey metal.
- Buttons should remain rectangular and compact.
- Do not use bright fills, gradients, pill shapes, or plastic-like shine.

## Progress Bar Rules

- Bars are mechanical slots with outer frame, black inner track, fill bevel, small damaged ticks.
- Each bar has icon, label, numeric value, dark inset track, 2 px pixel frame.
- HP uses dark red/rust red.
- Stamina/fuel uses dusty amber or military green.
- Energy uses muted grey-blue/teal.
- Vehicle durability uses metal grey/olive or dull orange warning when low.
- Values must remain readable inside or beside the bar.

## Icon Rules

- Icons are 16-24 px hard-edged pixel symbols inside 28-44 px metal wells.
- HUD icons use 22 px drawn symbol inside 28 px frame.
- Compact slot icons use 34x30 control area.
- Use wasteland military symbols: ammo shell, gear, coin/metal token, fuel can, med kit, shield, tank tread, radio, crate.
- Icon palettes: dull metal, rust, dusty tan, dark red, muted teal, military green.
- Icons must be blocky pixel silhouettes with no smoothing or gradients.
- Avoid cute faces, round toy gears, glossy app icons, high-saturation fills.

## Inventory Slot Rules

- Slots are 44x44 px.
- Slots look like military tool crate cells or old metal warehouse bins.
- Use square wells, heavy dark bevels, muted metal interiors.
- Compact pixel frame, dark recessed fill, rusty border.
- Hover and selected states are border changes, not bright fill changes.
- Selected state may use dull yellow warning trim or muted green scan trim.
- Slots show icon first; text labels are optional and must not crowd the slot.

## Dialog Box Rules

- Dialog boxes resemble radio/terminal panels or riveted metal nameplates.
- Use standard pixel panel frame.
- Speaker/title uses `FONT_SECTION` in small top metal label.
- Body text uses `FONT_BODY` on dark inset metal.
- Body text is dusty tan with enough padding for Chinese line breaks.
- Continue prompts are small mechanical indicators, not cute arrows.
- Dialog boxes stay at bottom-left or bottom-wide, must not cover central action lane.

## Battle UI Rules

- Battle meters sit top-left below main HUD.
- Battle commands use same old control-console button style as HUD.
- Enemy bars and target info resemble tactical target cards: dark field, red HP slot, muted armor bar, small warning icon.
- Battle log sits bottom-left above command bar, looks like old radio/terminal output.
- Enemy HP uses same pixel meter style as player meters.
- Combat text must remain readable and no larger than `FONT_BODY` except phase/status line.

## Forbidden Colors And Styles

- No bright pure white UI text except tiny highlights inside icons.
- No neon purple/blue gradients.
- No high-saturation cyan/green/pink/yellow toy colors.
- No beige/cream fantasy parchment theme.
- No rounded pill buttons/cards.
- No cute/Q-style icons, plastic-looking controls, mobile app/web button styling.
- No soft shadows larger than style guide shadow.
- No blurred, antialiased, glassmorphism, or high-resolution illustration UI.
- No large clean solid-color blocks.
- No one-off hardcoded UI colors when a style guide token exists.

## Godot Implementation

- All new UI must use `game/ui_style_guide.gd` constants and helpers instead of local one-off colors, sizes, borders, or spacing.
- HUD root uses `CanvasLayer`.
- UI is built from `Control` nodes: `PanelContainer`, `MarginContainer`, `HBoxContainer`, `VBoxContainer`, `GridContainer`.
- Shared visuals: `res://themes/wasteland_ui_theme.tres` and reusable scenes in `res://scenes/ui/`.
- Use `StyleBoxFlat` for generated metal surfaces. Use `NinePatchRect/NinePatchTexture` only when hand-authored pixel border resources exist.
- Do not flatten the UI into one image.
- Use `TextureRect` or custom-drawn `Control` icons for icons; keep nearest-neighbor filtering.
- Use reusable components: metal panels, buttons, progress bars, inventory slots, dialog boxes, battle command buttons.
- Project texture filtering must stay nearest: `textures/canvas_textures/default_texture_filter=0`.
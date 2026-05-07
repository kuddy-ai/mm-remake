# UI Style Guide

This project uses one shared UI language for the wasteland Terraria-like pixel prototype. All new UI must use `game/ui_style_guide.gd` constants and helpers instead of local one-off colors, sizes, borders, or spacing.

## Visual Audit Baseline

The reference images use heavy dark metal panels, rusty brass trim, worn text, rivets, scratches, oily seams, low-saturation status colors, and military control-console buttons. UI must feel like vehicle dashboards, workshop plates, old terminals, ammo crates, and field equipment.

The previous prototype drifted away from the references in these areas:

- Buttons and slots read too much like clean web/mobile controls.
- Several icons used bright toy-like colors and rounded/cute silhouettes.
- Panels lacked material detail: too few seams, scratches, rivets, rust chips, and dark edge wear.
- Progress bars were readable but too clean, with not enough mechanical slot/instrument feel.
- Cyan/green highlights were too saturated compared with the reference images.

Corrective direction:

- Prefer dark iron, rust brown, dirty sand, military green, and desaturated gray-blue.
- Use bright colors only as tiny status lamps or edge highlights.
- Every primary HUD panel should have double borders, rivets, scratches, rust, and recessed inner metal.
- Buttons must look like old mechanical controls, not rounded or plastic UI.

## 1. UI Palette

- `BG_DARK`: near-black wasteland backing panels.
- `PANEL_BG`: dark oxidized metal panel fill.
- `PANEL_INSET`: recessed inner panel fill.
- `BORDER`: rusty brass pixel border.
- `BORDER_DARK`: lower/outer shadow border.
- `TEXT`: primary readable sand text.
- `TEXT_MUTED`: secondary worn metal text.
- `GOLD`: headings, important values, selected equipment.
- `CYAN`: active system highlights and functional accents.
- `DANGER`: HP, enemy, warning.
- `STAMINA`: stamina/energy bars.
- `ARMOR`: vehicle durability.
- `SCRAP`: metal and money icons.

## 2. Font Sizes

- `FONT_TITLE = 20`: major HUD title only.
- `FONT_SECTION = 16`: panel headers and battle phase text.
- `FONT_BODY = 13`: standard values and labels.
- `FONT_SMALL = 11`: secondary metadata.
- `FONT_TINY = 10`: status captions.

## 3. Panel Border Rules

- All panels use square pixel corners.
- Border width is 2 px.
- Panels use dark fill, rusty brass border, and a small 2 px shadow.
- No gradients, blur, transparency-heavy glass, rounded cards, or antialiasing-heavy surfaces.

## 4. Button State Rules

- Normal: dark metal fill, rusty brass border, sand text.
- Hover: green-cyan active fill/border, cyan text.
- Pressed: warm rust fill/border, gold text.
- Buttons should remain rectangular and compact.

## 5. Progress Bar Rules

- Progress bars are custom pixel meters, not default theme bars.
- Each bar has an icon, label, numeric value, dark inset track, and 2 px pixel frame.
- HP uses red, stamina/energy uses amber/cyan, vehicle durability uses armor green-gray.

## 6. Icon Size Rules

- HUD icons use a 22 px drawn symbol inside a 28 px frame.
- Compact slot icons use a 34x30 control area.
- Icons must be blocky pixel silhouettes with no smoothing or gradients.

## 7. Inventory Slot Rules

- Slots are 44x44 px.
- Use compact pixel frame, dark recessed fill, rusty border.
- Slots show icon first; text labels are optional and must not crowd the slot.

## 8. Dialog Box Rules

- Dialog boxes use the standard pixel panel frame.
- Body text uses `FONT_BODY`; speaker/title uses `FONT_SECTION`.
- Dialog boxes stay at bottom-left or bottom-wide and must not cover the central action lane.

## 9. Battle UI Rules

- Battle meters sit top-left below the main HUD.
- Battle log sits bottom-left above the command bar.
- Enemy HP uses the same pixel meter style as player meters.
- Combat text must remain readable and no larger than `FONT_BODY` except phase/status line.

## 10. Forbidden Colors And Styles

- No bright pure white UI text except tiny highlights inside icons.
- No neon purple/blue gradients.
- No high-saturation cyan/green/pink/yellow toy colors.
- No beige/cream fantasy parchment theme.
- No rounded pill buttons/cards.
- No cute/Q-style icons, plastic-looking controls, or mobile app/web button styling.
- No soft shadows larger than the style guide shadow.
- No blurred, antialiased, glassmorphism, or high-resolution illustration UI.
- No one-off hardcoded UI colors when a style guide token exists.

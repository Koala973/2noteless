# Doodle-Brutalism Design System

## Color Token Bridge

Figma color styles and Xcode asset names must stay 1:1:

- `PaperBg` -> `2noteless/Resources/Assets.xcassets/PaperBg.colorset`
- `MarkerBlack` -> `2noteless/Resources/Assets.xcassets/MarkerBlack.colorset`
- `BubblegumPink` -> `2noteless/Resources/Assets.xcassets/BubblegumPink.colorset`
- `HighVisYellow` -> `2noteless/Resources/Assets.xcassets/HighVisYellow.colorset`

SwiftUI views should use `DoodlePalette` or `Color("TokenName")`. Do not hardcode hex colors inside view code.

## Placeholder Asset Strategy

First-pass UI must remain visible in Preview even when image files are missing.

- Prefer SF Symbols plus Doodle modifiers for icons.
- Prefer code-drawn placeholders with `Canvas`, `Shape`, or `Color` blocks for avatars and illustrations.
- Use bundled images only when they are already present in `Assets.xcassets`.

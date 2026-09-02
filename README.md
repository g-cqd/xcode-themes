# Xcode Themes

18 hand-made color schemes for Xcode, each shipped in three font variants (SF Mono, JetBrains Mono, Maple Mono) and in **both** theme formats:

| Format | Extension | Xcode |
|---|---|---|
| Classic | `.xccolortheme` (plist) | any version |
| Recipe | `.xcworkspacecolortheme` (JSON, OKLCH in Display P3) | 27+ |

That's 54 classic + 54 recipe files in [`themes/`](themes). The recipe format is colors-only (fonts are set separately in Xcode 27), so the three font variants of a palette are identical there.

## Install

```bash
git clone git@github.com:g-cqd/xcode-themes.git && cd xcode-themes && ./install.sh
```

or copy the files you want into `~/Library/Developer/Xcode/UserData/FontAndColorThemes/`, then pick the theme in **Settings › Themes**.

## Previews

Rendered straight from the theme files by [`tools/render-previews.py`](tools/render-previews.py); the swatch row shows keyword, project type, system type, project function, system function, variable, string, number, attribute, preprocessor, comment, and plain text.

## Dark

### Ayu Dark

![Ayu Dark](previews/Ayu-Dark.svg)

### Ayu Dark Vibrant

![Ayu Dark Vibrant](previews/Ayu-Dark-Vibrant.svg)

### Ayu Neutral

![Ayu Neutral](previews/Ayu-Neutral.svg)

### Ayu Neutral Vibrant

![Ayu Neutral Vibrant](previews/Ayu-Neutral-Vibrant.svg)

### Black & White

![Black & White](previews/Black-and-White.svg)

### Comfort Amber Dark

![Comfort Amber Dark](previews/Comfort-Amber-Dark.svg)

### Comfort Brown Dark

![Comfort Brown Dark](previews/Comfort-Brown-Dark.svg)

### Comfort Red Mono

![Comfort Red Mono](previews/Comfort-Red-Mono.svg)

### Comfort Red Poly

![Comfort Red Poly](previews/Comfort-Red-Poly.svg)

### GitHub Dark

![GitHub Dark](previews/GitHub-Dark.svg)

### GitHub Dark Vibrant

![GitHub Dark Vibrant](previews/GitHub-Dark-Vibrant.svg)

## Light

### Ayu Light

![Ayu Light](previews/Ayu-Light.svg)

### Ayu Light Vibrant

![Ayu Light Vibrant](previews/Ayu-Light-Vibrant.svg)

### Comfort Amber Light

![Comfort Amber Light](previews/Comfort-Amber-Light.svg)

### Comfort Brown Light

![Comfort Brown Light](previews/Comfort-Brown-Light.svg)

### GitHub Light

![GitHub Light](previews/GitHub-Light.svg)

### GitHub Light Vibrant

![GitHub Light Vibrant](previews/GitHub-Light-Vibrant.svg)

### White & Black

![White & Black](previews/White-and-Black.svg)

## Tools

- `tools/xccolortheme-to-workspace.swift` — converts a classic theme to the Xcode 27 recipe format, matching Xcode's own importer to four decimals (generic-RGB gamma 1.8 → Display P3 → OKLCH, alpha colors flattened onto the background in gamma-encoded P3). Build with `swiftc -O -framework AppKit -o convert tools/xccolortheme-to-workspace.swift`, then `./convert convert In.xccolortheme Out.xcworkspacecolortheme`.
- `tools/render-previews.py themes previews` — regenerates the SVG previews.

## License

MIT

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

<details>
<summary><b>Ayu Dark</b></summary>

![Ayu Dark](previews/Ayu-Dark.svg)

</details>

<details>
<summary><b>Ayu Dark Vibrant</b></summary>

![Ayu Dark Vibrant](previews/Ayu-Dark-Vibrant.svg)

</details>

<details>
<summary><b>Ayu Neutral</b></summary>

![Ayu Neutral](previews/Ayu-Neutral.svg)

</details>

<details>
<summary><b>Ayu Neutral Vibrant</b></summary>

![Ayu Neutral Vibrant](previews/Ayu-Neutral-Vibrant.svg)

</details>

<details>
<summary><b>Black & White</b></summary>

![Black & White](previews/Black-and-White.svg)

</details>

<details>
<summary><b>Comfort Amber Dark</b></summary>

![Comfort Amber Dark](previews/Comfort-Amber-Dark.svg)

</details>

<details>
<summary><b>Comfort Brown Dark</b></summary>

![Comfort Brown Dark](previews/Comfort-Brown-Dark.svg)

</details>

<details>
<summary><b>Comfort Red Mono</b></summary>

![Comfort Red Mono](previews/Comfort-Red-Mono.svg)

</details>

<details>
<summary><b>Comfort Red Poly</b></summary>

![Comfort Red Poly](previews/Comfort-Red-Poly.svg)

</details>

<details>
<summary><b>GitHub Dark</b></summary>

![GitHub Dark](previews/GitHub-Dark.svg)

</details>

<details>
<summary><b>GitHub Dark Vibrant</b></summary>

![GitHub Dark Vibrant](previews/GitHub-Dark-Vibrant.svg)

</details>

## Light

<details>
<summary><b>Ayu Light</b></summary>

![Ayu Light](previews/Ayu-Light.svg)

</details>

<details>
<summary><b>Ayu Light Vibrant</b></summary>

![Ayu Light Vibrant](previews/Ayu-Light-Vibrant.svg)

</details>

<details>
<summary><b>Comfort Amber Light</b></summary>

![Comfort Amber Light](previews/Comfort-Amber-Light.svg)

</details>

<details>
<summary><b>Comfort Brown Light</b></summary>

![Comfort Brown Light](previews/Comfort-Brown-Light.svg)

</details>

<details>
<summary><b>GitHub Light</b></summary>

![GitHub Light](previews/GitHub-Light.svg)

</details>

<details>
<summary><b>GitHub Light Vibrant</b></summary>

![GitHub Light Vibrant](previews/GitHub-Light-Vibrant.svg)

</details>

<details>
<summary><b>White & Black</b></summary>

![White & Black](previews/White-and-Black.svg)

</details>

## Tools

- `tools/xccolortheme-to-workspace.swift` — converts a classic theme to the Xcode 27 recipe format, matching Xcode's own importer to four decimals (generic-RGB gamma 1.8 → Display P3 → OKLCH, alpha colors flattened onto the background in gamma-encoded P3). Build with `swiftc -O -framework AppKit -o convert tools/xccolortheme-to-workspace.swift`, then `./convert convert In.xccolortheme Out.xcworkspacecolortheme`.
- `tools/render-previews.py themes previews` — regenerates the SVG previews.

## License

MIT

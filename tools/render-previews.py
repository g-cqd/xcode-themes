#!/usr/bin/env python3
"""Render an SVG preview of each Xcode theme (one per palette; font variants share colors)."""
import plistlib, re, sys, html, os, glob, collections

def hexcolor(s):
    r,g,b,a = (list(map(float, s.split())) + [1.0])[:4]
    def enc(v):                       # generic RGB (gamma 1.8) -> linear -> sRGB
        lin = v ** 1.8
        return 12.92*lin if lin <= 0.0031308 else 1.055*lin**(1/2.4) - 0.055
    return "#%02x%02x%02x" % tuple(round(max(0,min(1,enc(v)))*255) for v in (r,g,b)), a

SNIPPET = [  # (token, syntax key) rows of a small Swift sample
 [("// Xcode theme preview — Ayu, Comfort, GitHub…", "comment")],
 [("import ", "keyword"), ("SwiftUI", "identifier.type.system")],
 [],
 [("/// A tiny view model showing every syntax color.", "comment.doc")],
 [("@Observable ", "attribute"), ("final class ", "keyword"), ("Counter", "declaration.type"), (" {", "plain")],
 [("    ", "plain"), ("var ", "keyword"), ("value", "declaration.other"), (": ", "plain"), ("Int", "identifier.type.system"), (" = ", "plain"), ("0", "number")],
 [("    ", "plain"), ("let ", "keyword"), ("label", "declaration.other"), (" = ", "plain"), ('"Count: \\(value)"', "string")],
 [("    ", "plain"), ("func ", "keyword"), ("bump", "declaration.other"), ("(", "plain"), ("by", "declaration.other"), (" step: ", "plain"), ("Int", "identifier.type.system"), (") { ", "plain"), ("value", "identifier.variable"), (" += ", "plain"), ("step", "identifier.variable"), (" }", "plain")],
 [("}", "plain")],
 [],
 [("struct ", "keyword"), ("CounterView", "declaration.type"), (": ", "plain"), ("View", "identifier.type.system"), (" {", "plain")],
 [("    ", "plain"), ("@State ", "attribute"), ("private var ", "keyword"), ("model", "declaration.other"), (" = ", "plain"), ("Counter", "identifier.class"), ("()", "plain")],
 [("    ", "plain"), ("var ", "keyword"), ("body", "declaration.other"), (": ", "plain"), ("some ", "keyword"), ("View", "identifier.type.system"), (" {", "plain")],
 [("        ", "plain"), ("Button", "identifier.class.system"), ("(", "plain"), ("model", "identifier.variable"), (".", "plain"), ("label", "identifier.variable"), (") { ", "plain"), ("model", "identifier.variable"), (".", "plain"), ("bump", "identifier.function"), ("(by: ", "plain"), ("1", "number"), (") }", "plain")],
 [("            .", "plain"), ("padding", "identifier.function.system"), ("(", "plain"), (".pi", "identifier.constant.system"), (" * ", "plain"), ("2", "number"), (")", "plain")],
 [("            .", "plain"), ("accessibilityLabel", "identifier.function.system"), ("(", "plain"), ('"Increment"', "string"), (")", "plain")],
 [("    ", "plain"), ("}", "plain")],
 [("}", "plain")],
 [],
 [("#if ", "preprocessor"), ("DEBUG", "identifier.macro"), ("   ", "plain"), ("// MARK: - Regex & chars", "mark")],
 [("let ", "keyword"), ("re", "declaration.other"), (" = ", "plain"), ("/[a-z]+\\d{2}/", "regex"), ("; ", "plain"), ("let ", "keyword"), ("c", "declaration.other"), (": ", "plain"), ("Character", "identifier.type.system"), (" = ", "plain"), ('"x"', "character")],
 [("print", "identifier.function.system"), ("(", "plain"), ('"https://developer.apple.com"', "url"), (")", "plain")],
 [("#endif", "preprocessor")],
]

def render(path, out):
    t = plistlib.load(open(path, "rb"))
    syn = t["DVTSourceTextSyntaxColors"]
    bg, _ = hexcolor(t["DVTSourceTextBackground"])
    cur, cura = hexcolor(t["DVTSourceTextCurrentLineHighlightColor"])
    sel, sela = hexcolor(t["DVTSourceTextSelectionColor"])
    W, LH, PAD, FS = 760, 21, 22, 13
    H = PAD*2 + LH*len(SNIPPET) + 44
    o = [f'<svg xmlns="http://www.w3.org/2000/svg" width="{W}" height="{H}" viewBox="0 0 {W} {H}" font-family="SF Mono, JetBrains Mono, Menlo, Consolas, monospace" font-size="{FS}">',
         f'<rect width="{W}" height="{H}" rx="10" fill="{bg}"/>',
         f'<rect x="0" y="{PAD+LH*4-15}" width="{W}" height="{LH}" fill="{cur}" fill-opacity="{cura}"/>',
         f'<rect x="{PAD+8*7.9}" y="{PAD+LH*6-15}" width="{16*7.9}" height="{LH}" fill="{sel}" fill-opacity="{sela}"/>']
    for i, row in enumerate(SNIPPET):
        y = PAD + LH*i
        parts = []
        for text, key in row:
            c, a = hexcolor(syn.get("xcode.syntax."+key, syn["xcode.syntax.plain"]))
            op = f' fill-opacity="{a:.3f}"' if a < 0.999 else ""
            parts.append(f'<tspan fill="{c}"{op}>{html.escape(text)}</tspan>')
        o.append(f'<text x="{PAD}" y="{y}" xml:space="preserve">{"".join(parts)}</text>')
    # swatch strip of the main syntax colors
    keys = ["keyword","identifier.type","identifier.type.system","identifier.function","identifier.function.system","identifier.variable","string","number","attribute","preprocessor","comment","plain"]
    x0, y0 = PAD, PAD + LH*len(SNIPPET) + 6
    for j, k in enumerate(keys):
        c, a = hexcolor(syn["xcode.syntax."+k])
        o.append(f'<rect x="{x0 + j*58}" y="{y0}" width="50" height="22" rx="5" fill="{c}" fill-opacity="{a:.3f}"><title>{k}</title></rect>')
    o.append('</svg>')
    open(out, "w").write("\n".join(o))

if __name__ == "__main__":
    src, dst = sys.argv[1], sys.argv[2]
    os.makedirs(dst, exist_ok=True)
    seen = set()
    for f in sorted(glob.glob(os.path.join(src, "*.xccolortheme"))):
        name = re.sub(r" \((SF Mono|JetBrains Mono|Maple Mono)\)$", "", os.path.basename(f)[:-len(".xccolortheme")])
        if name in seen: continue
        seen.add(name)
        render(f, os.path.join(dst, name.replace(" & ", "-and-").replace(" ", "-") + ".svg"))
        print("rendered", name)

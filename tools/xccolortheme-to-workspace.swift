import Foundation
import AppKit

// MARK: - Color math
struct LCH { var L: Double; var C: Double; var H: Double; var a: Double }

let via = CommandLine.arguments.first(where: { $0.hasPrefix("--via=") })?.dropFirst(6) ?? "p3"
let compMode = CommandLine.arguments.first(where: { $0.hasPrefix("--composite=") })?.dropFirst(12) ?? "p3"
func srgbDecode(_ v: Double) -> Double { v <= 0.04045 ? v/12.92 : pow((v+0.055)/1.055, 2.4) }
func comps(_ c: NSColor, _ sp: NSColorSpace) -> (Double, Double, Double) {
    let x = c.usingColorSpace(sp)!; return (Double(x.redComponent), Double(x.greenComponent), Double(x.blueComponent))
}
// returns linear sRGB-primaries RGB (what the OKLab matrix expects)
func linearSRGB(_ c: NSColor, space: NSColorSpace) -> (Double, Double, Double) {
    if via == "p3" {
        let (r,g,b) = comps(c, .displayP3)
        let (R,G,B) = (srgbDecode(r), srgbDecode(g), srgbDecode(b))
        // P3 linear -> XYZ(D65) -> linear sRGB
        let X = 0.4865709486*R + 0.2656676932*G + 0.1982172852*B
        let Y = 0.2289745641*R + 0.6917385218*G + 0.0792869141*B
        let Z = 0.0000000000*R + 0.0451133819*G + 1.0439443689*B
        return ( 3.2404542*X - 1.5371385*Y - 0.4985314*Z,
                -0.9692660*X + 1.8760108*Y + 0.0415560*Z,
                 0.0556434*X - 0.2040259*Y + 1.0572252*Z)
    }
    let lin = CGColorSpace(name: CGColorSpace.linearSRGB)!
    let cg = c.cgColor.converted(to: lin, intent: .relativeColorimetric, options: nil)!
    let k = cg.components!
    return (Double(k[0]), Double(k[1]), Double(k[2]))
}

func oklch(_ rgb: (Double, Double, Double), alpha: Double) -> LCH {
    let (r, g, b) = rgb
    let l = 0.4122214708*r + 0.5363325363*g + 0.0514459929*b
    let m = 0.2119034982*r + 0.6806995451*g + 0.1073969566*b
    let s = 0.0883024619*r + 0.2817188376*g + 0.6299787005*b
    let l_ = cbrt(l), m_ = cbrt(m), s_ = cbrt(s)
    let L = 0.2104542553*l_ + 0.7936177850*m_ - 0.0040720468*s_
    let A = 1.9779984951*l_ - 2.4285922050*m_ + 0.4505937099*s_
    let B = 0.0259040371*l_ + 0.7827717662*m_ - 0.8086757660*s_
    var h = atan2(B, A); if h < 0 { h += 2 * .pi }
    return LCH(L: L, C: sqrt(A*A + B*B), H: h, a: alpha)
}

func parse(_ s: String) -> (Double, Double, Double, Double) {
    let p = s.split(separator: " ").compactMap { Double($0) }
    return (p[0], p[1], p[2], p.count > 3 ? p[3] : 1)
}

// MARK: - Conversion
let compositeInLinear = CommandLine.arguments.contains("--linear-composite")
let spaceName = CommandLine.arguments.first(where: { $0.hasPrefix("--space=") })?.dropFirst(8) ?? "generic"
let space: NSColorSpace = spaceName == "srgb" ? .sRGB : spaceName == "device" ? .deviceRGB : .genericRGB

func nscolor(_ t: (Double, Double, Double, Double)) -> NSColor {
    NSColor(colorSpace: space, components: [CGFloat(t.0), CGFloat(t.1), CGFloat(t.2), CGFloat(t.3)], count: 4)
}

func convert(oldPath: String) -> [String: Any] {
    let data = FileManager.default.contents(atPath: oldPath)!
    let plist = try! PropertyListSerialization.propertyList(from: data, format: nil) as! [String: Any]
    let syn = plist["DVTSourceTextSyntaxColors"] as! [String: String]
    let bgT = parse(plist["DVTSourceTextBackground"] as! String)
    let bgLin = linearSRGB(nscolor(bgT), space: space)

    func colorNode(_ str: String, keepOpacity: Bool) -> [String: Any] {
        let t = parse(str)
        var lin = linearSRGB(nscolor(t), space: space)
        var alpha = t.3
        if !keepOpacity && alpha < 1 {
            switch compMode {
            case "linear":
                lin = (bgLin.0 + alpha*(lin.0-bgLin.0), bgLin.1 + alpha*(lin.1-bgLin.1), bgLin.2 + alpha*(lin.2-bgLin.2))
            case "srgb", "p3":
                let sp: NSColorSpace = compMode == "srgb" ? .sRGB : .displayP3
                let f = comps(nscolor(t), sp), g = comps(nscolor(bgT), sp)
                let m = (g.0 + alpha*(f.0-g.0), g.1 + alpha*(f.1-g.1), g.2 + alpha*(f.2-g.2))
                lin = linearSRGB(NSColor(colorSpace: sp, components: [CGFloat(m.0), CGFloat(m.1), CGFloat(m.2), 1], count: 4), space: sp)
            case "oklab":
                // lerp in OKLab, then back to LCH via a tiny detour: convert both to Lab
                func lab(_ p: (Double,Double,Double)) -> (Double,Double,Double) {
                    let l = 0.4122214708*p.0 + 0.5363325363*p.1 + 0.0514459929*p.2
                    let m = 0.2119034982*p.0 + 0.6806995451*p.1 + 0.1073969566*p.2
                    let s = 0.0883024619*p.0 + 0.2817188376*p.1 + 0.6299787005*p.2
                    let l_ = cbrt(l), m_ = cbrt(m), s_ = cbrt(s)
                    return (0.2104542553*l_ + 0.7936177850*m_ - 0.0040720468*s_,
                            1.9779984951*l_ - 2.4285922050*m_ + 0.4505937099*s_,
                            0.0259040371*l_ + 0.7827717662*m_ - 0.8086757660*s_)
                }
                let a1 = lab(lin), a0 = lab(bgLin)
                let L = a0.0 + alpha*(a1.0-a0.0), A = a0.1 + alpha*(a1.1-a0.1), B = a0.2 + alpha*(a1.2-a0.2)
                var h = atan2(B, A); if h < 0 { h += 2 * .pi }
                return ["chroma": ["exact": sqrt(A*A+B*B)], "gamut": "P3", "hue": ["radians": h], "lightness": ["exact": L], "opacity": 1.0]
            default:
                let c = (bgT.0 + alpha*(t.0-bgT.0), bgT.1 + alpha*(t.1-bgT.1), bgT.2 + alpha*(t.2-bgT.2), 1.0)
                lin = linearSRGB(nscolor(c), space: space)
            }
            alpha = 1
        }
        let x = oklch(lin, alpha: alpha)
        return ["chroma": ["exact": x.C], "gamut": "P3", "hue": ["radians": x.H], "lightness": ["exact": x.L], "opacity": alpha]
    }
    func c(_ key: String) -> [String: Any] { ["color": colorNode(syn[key]!, keepOpacity: false)] }
    func top(_ key: String, opacity: Bool) -> [String: Any] {
        [opacity ? "colorWithOpacity" : "color": colorNode(plist[key] as! String, keepOpacity: opacity)]
    }

    let overrides: [String: Any] = [
        "comment": c("xcode.syntax.comment"),
        "currentLineHighlight": top("DVTSourceTextCurrentLineHighlightColor", opacity: true),
        "insertionPointColor": top("DVTSourceTextInsertionPointColor", opacity: false),
        "invisibles": top("DVTSourceTextInvisiblesColor", opacity: false),
        "keyword": c("xcode.syntax.keyword"),
        "keyword.attribute": c("xcode.syntax.attribute"),
        "link": c("xcode.syntax.url"),
        "markdown": c("xcode.syntax.comment.doc"),
        "memberDeclaration": c("xcode.syntax.declaration.other"),
        "number": c("xcode.syntax.number"),
        "number.character": c("xcode.syntax.character"),
        "otherMember": c("xcode.syntax.identifier.function.system"),
        "otherMember.constant": c("xcode.syntax.identifier.constant.system"),
        "otherMember.function": c("xcode.syntax.identifier.function.system"),
        "otherMember.variable": c("xcode.syntax.identifier.variable.system"),
        "otherType": c("xcode.syntax.identifier.type.system"),
        "otherType.class": c("xcode.syntax.identifier.class.system"),
        "otherType.type": c("xcode.syntax.identifier.type.system"),
        "plainText": c("xcode.syntax.plain"),
        "preprocessor": c("xcode.syntax.preprocessor"),
        "preprocessor.macro": c("xcode.syntax.identifier.macro"),
        "preprocessor.macroSystem": c("xcode.syntax.identifier.macro.system"),
        "projectMember": c("xcode.syntax.identifier.function"),
        "projectMember.constant": c("xcode.syntax.identifier.constant"),
        "projectMember.function": c("xcode.syntax.identifier.function"),
        "projectMember.variable": c("xcode.syntax.identifier.variable"),
        "projectType": c("xcode.syntax.identifier.type"),
        "projectType.class": c("xcode.syntax.identifier.class"),
        "projectType.type": c("xcode.syntax.identifier.type"),
        "selectedTextBackgroundColor": top("DVTSourceTextSelectionColor", opacity: true),
        "string": c("xcode.syntax.string"),
        "string.regex": c("xcode.syntax.regex"),
        "typeDeclaration": c("xcode.syntax.declaration.type"),
    ]
    let bgNode = colorNode(plist["DVTSourceTextBackground"] as! String, keepOpacity: false)
    let bgL = (bgNode["lightness"] as! [String: Double])["exact"]!
    return [
        "fileVersion": 1,
        "recipe": [
            "background": ["customColor": bgNode],
            "colorScheme": bgL < 0.5 ? "dark" : "light",
            "palette": [
                "colorGranularity": "expanded",
                "colorOverrides": overrides,
                "primary": ["custom": colorNode(syn["xcode.syntax.keyword"]!, keepOpacity: false)],
                "secondary": ["custom": bgNode],
            ],
        ],
    ]
}

// MARK: - Validation against a reference file
func flatten(_ o: Any, _ p: String = "", into out: inout [String: Double]) {
    if let d = o as? [String: Any] {
        for (k, v) in d { flatten(v, p.isEmpty ? k : p + "." + k, into: &out) }
    } else if let n = o as? Double { out[p] = n } else if let n = o as? Int { out[p] = Double(n) }
}

let args = CommandLine.arguments.filter { !$0.hasPrefix("--") }
if args.count >= 4 && args[1] == "validate" {
    let mine = convert(oldPath: args[2])
    let ref = try! JSONSerialization.jsonObject(with: Data(contentsOf: URL(fileURLWithPath: args[3])))
    var a: [String: Double] = [:], b: [String: Double] = [:]
    flatten(mine, into: &a); flatten(ref, into: &b)
    var maxErr = 0.0; var worst = ""
    for (k, v) in b where !k.hasPrefix("recipe.palette.primary") {
        guard let m = a[k] else { print("MISSING in mine: \(k)"); continue }
        let e = abs(m - v)
        if e > maxErr && !(k.hasSuffix("hue.radians") && (b[k.replacingOccurrences(of: "hue.radians", with: "chroma.exact")] ?? 1) < 1e-3) { maxErr = e; worst = k }
    }
    for k in a.keys where b[k] == nil { print("EXTRA in mine: \(k)") }
    print(String(format: "max abs error %.6f at %@", maxErr, worst))
} else if args.count >= 4 && args[1] == "convert" {
    let out = convert(oldPath: args[2])
    let data = try! JSONSerialization.data(withJSONObject: out, options: [.prettyPrinted, .sortedKeys])
    try! data.write(to: URL(fileURLWithPath: args[3]))
    print("wrote \(args[3])")
}

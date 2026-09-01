import AppKit
import CoreText
import Foundation

// Exports the app's wordmark as outlines. Same string, same face, same kern
// table as Joinery/Home/HomeWordmark.swift — the per-pair values are the whole
// point of the thing, so they're copied here rather than approximated, and a
// change to them there is a re-run of this.

let text = "Joinery"
let kernEm: [CGFloat] = [-0.050, -0.042, -0.036, -0.038, -0.028, 0.012, 0]

func font(size: CGFloat) -> NSFont { .systemFont(ofSize: size, weight: .bold) }

func attributed(size: CGFloat) -> NSAttributedString {
  let out = NSMutableAttributedString()
  for (index, character) in text.enumerated() {
    var attrs: [NSAttributedString.Key: Any] = [.font: font(size: size)]
    let kern = kernEm[index] * size
    if kern != 0 { attrs[.kern] = kern }
    out.append(NSAttributedString(string: String(character), attributes: attrs))
  }
  return out
}

// The app derives its point size from a target width; render at the size a
// 402pt-wide iPhone produces, so the optical-size axis lands where it does on
// device rather than wherever a round number would put it.
let widthPerPoint = attributed(size: 100).size().width / 100
let pointSize = (402 * 0.30) / widthPerPoint

let line = CTLineCreateWithAttributedString(attributed(size: pointSize))
let glyphPath = CGMutablePath()
for run in (CTLineGetGlyphRuns(line) as! [CTRun]) {
  let attrs = CTRunGetAttributes(run) as NSDictionary
  let runFont = attrs[kCTFontAttributeName as String] as! CTFont
  let count = CTRunGetGlyphCount(run)
  var glyphs = [CGGlyph](repeating: 0, count: count)
  var positions = [CGPoint](repeating: .zero, count: count)
  CTRunGetGlyphs(run, CFRange(location: 0, length: count), &glyphs)
  CTRunGetPositions(run, CFRange(location: 0, length: count), &positions)
  for i in 0..<count {
    guard let g = CTFontCreatePathForGlyph(runFont, glyphs[i], nil) else { continue }
    let t = CGAffineTransform(translationX: positions[i].x, y: positions[i].y)
    glyphPath.addPath(g, transform: t)
  }
}

// Font space is y-up and origin-on-baseline; SVG is y-down from the top left.
let box = glyphPath.boundingBoxOfPath
var flip = CGAffineTransform(a: 1, b: 0, c: 0, d: -1, tx: -box.minX, ty: box.maxY)
let final = glyphPath.copy(using: &flip)!

func n(_ v: CGFloat) -> String {
  let r = (Double(v) * 100).rounded() / 100
  return r == r.rounded() ? String(Int(r)) : String(r)
}

var d = ""
final.applyWithBlock { element in
  let p = element.pointee.points
  switch element.pointee.type {
  case .moveToPoint: d += "M\(n(p[0].x)) \(n(p[0].y))"
  case .addLineToPoint: d += "L\(n(p[0].x)) \(n(p[0].y))"
  case .addQuadCurveToPoint: d += "Q\(n(p[0].x)) \(n(p[0].y)) \(n(p[1].x)) \(n(p[1].y))"
  case .addCurveToPoint:
    d += "C\(n(p[0].x)) \(n(p[0].y)) \(n(p[1].x)) \(n(p[1].y)) \(n(p[2].x)) \(n(p[2].y))"
  case .closeSubpath: d += "Z"
  @unknown default: break
  }
}

FileHandle.standardError.write(
  "point size \(n(pointSize)) · box \(n(box.width))x\(n(box.height)) · \(d.count) bytes of path\n"
    .data(using: .utf8)!)

print("""
  <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 \(n(box.width)) \(n(box.height))" role="img" aria-label="Joinery"><path d="\(d)" fill="currentColor"/></svg>
  """)

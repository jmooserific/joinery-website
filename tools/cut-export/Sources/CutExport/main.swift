import CoreGraphics
import Foundation
import PuzzleEngine

// Exports one real generated cut as an SVG. Same engine, same defaults, same
// seed as the app would use — the picture on the site is the artifact, not a
// drawing of it.

func arg(_ name: String, _ fallback: Double) -> Double {
  guard let i = CommandLine.arguments.firstIndex(of: "--\(name)"),
    i + 1 < CommandLine.arguments.count, let v = Double(CommandLine.arguments[i + 1])
  else { return fallback }
  return v
}

let width = arg("width", 1200)
let height = arg("height", 800)
let pieces = Int(arg("pieces", 48))
let seed = UInt64(arg("seed", 7))
let strokeDivisor = arg("stroke", 620)

let algorithm = JitteredGridCutAlgorithm()
let result = try algorithm.generate(
  frameSize: CGSize(width: width, height: height), targetPieceCount: pieces, seed: seed)
let geometry = result.geometry

func n(_ value: CGFloat) -> String {
  let rounded = (Double(value) * 10).rounded() / 10
  return rounded == rounded.rounded() ? String(Int(rounded)) : String(rounded)
}

func path(_ curve: SideCurve) -> String {
  var out = "M\(n(curve.start.x)) \(n(curve.start.y))"
  for segment in curve.segments {
    switch segment {
    case .line(let to):
      out += "L\(n(to.x)) \(n(to.y))"
    case .cubic(let to, let c1, let c2):
      out += "C\(n(c1.x)) \(n(c1.y)) \(n(c2.x)) \(n(c2.y)) \(n(to.x)) \(n(to.y))"
    }
  }
  return out
}

// Every side once, from the shared-side cache, so an interior side shared by
// two pieces is stroked once rather than twice.
let d = geometry.sideCurves.keys.sorted().map { path(geometry.sideCurves[$0]!) }.joined(separator: "")

// A blank side — an interior side the algorithm chose to cut without a knob —
// is the thing that reads as a false edge on a still picture, so a seed being
// shopped for a web page wants to be judged on how many it has. Slivers (the
// short flat side a staggered junction leaves between a diagonal pair) are
// also flat, but they carry no bond, which is how they're told apart here.
var blanks = 0
var slivers = 0
var boundary = 0
for piece in geometry.pieces {
  for side in piece.sides where side.profile == .flat {
    guard let neighbor = side.neighbor else {
      boundary += 1
      continue
    }
    let bonded = geometry.bonds.contains {
      ($0.first == piece.id && $0.second == neighbor)
        || ($0.first == neighbor && $0.second == piece.id)
    }
    if bonded { blanks += 1 } else { slivers += 1 }
  }
}
// Each interior side is walked from both of its pieces.
blanks /= 2
slivers /= 2

let dims = JitteredGridCutAlgorithm.gridDimensions(for: pieces, in: CGSize(width: width, height: height))
FileHandle.standardError.write(
  "seed \(seed) · \(geometry.pieces.count) pieces (\(dims.rows)x\(dims.columns)) · \(geometry.sideCurves.count) sides · blanks \(blanks) · slivers \(slivers) · \(d.count) bytes of path\n"
    .data(using: .utf8)!)

print(
  """
  <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 \(n(CGFloat(width))) \(n(CGFloat(height)))" fill="none" stroke="currentColor" stroke-width="\(((width / strokeDivisor) * 100).rounded() / 100)" stroke-linecap="round" stroke-linejoin="round" role="img" aria-label="A generated cut: \(geometry.pieces.count) pieces, no two alike."><path d="\(d)"/></svg>
  """)

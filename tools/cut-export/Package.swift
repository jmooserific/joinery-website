// swift-tools-version: 6.0
import PackageDescription

let package = Package(
  name: "CutExport",
  platforms: [.macOS(.v14)],
  dependencies: [.package(path: "../../../Joinery/PuzzleEngine")],
  targets: [
    .executableTarget(
      name: "CutExport",
      dependencies: [.product(name: "PuzzleEngine", package: "PuzzleEngine")]
    )
  ]
)

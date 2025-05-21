// swift-tools-version:5.5
import PackageDescription

let package = Package(
    name: "SwiftUIFormApp",
    platforms: [
        .iOS(.v14), .macOS(.v11)
    ],
    products: [
        .executable(name: "SwiftUIFormApp", targets: ["SwiftUIFormApp"])
    ],
    dependencies: [],
    targets: [
        .executableTarget(
            name: "SwiftUIFormApp",
            path: "Sources/SwiftUIFormApp"
        )
    ]
)

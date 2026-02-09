// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "Vox",
    platforms: [
        .macOS(.v14)
    ],
    products: [
        .executable(name: "Vox", targets: ["Vox"])
    ],
    targets: [
        .executableTarget(
            name: "Vox",
            dependencies: ["WhisperCpp"],
            path: "Vox",
            linkerSettings: [
                .linkedFramework("Accelerate"),
                .linkedFramework("Metal"),
                .linkedFramework("Foundation"),
                .linkedLibrary("c++")
            ]
        ),
        .binaryTarget(
            name: "WhisperCpp",
            path: "whisper.xcframework"
        )
    ]
)

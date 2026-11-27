// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "NoteEditPlusPlus",
    platforms: [
        .macOS(.v14)
    ],
    products: [
        .executable(
            name: "NoteEditPlusPlus",
            targets: ["NoteEditPlusPlus"]
        )
    ],
    targets: [
        .executableTarget(
            name: "NoteEditPlusPlus",
            path: "Sources/NoteEditPlusPlus"
        ),
        .testTarget(
            name: "NoteEditPlusPlusTests",
            dependencies: ["NoteEditPlusPlus"],
            path: "Tests/NoteEditPlusPlusTests"
        ),
    ]
)

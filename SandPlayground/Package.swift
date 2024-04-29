// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SandPlayground",
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        .package(url: "https://github.com/madmachineio/SwiftIO.git", branch: "main"),
        .package(url: "https://github.com/madmachineio/MadBoards.git", branch: "main"),
        .package(url: "https://github.com/madmachineio/MadDrivers.git", branch: "main"),
        .package(path: "../MadBoardBase"),
        .package(path: "../Sand")
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .executableTarget(
            name: "SandPlayground",
            dependencies: [
                "SwiftIO",
                "MadBoards",
                // Use specific library name rather than "MadDrivers" would speed up the build procedure.
                // .product(name: "MadDrivers", package: "MadDrivers")
                .product(name: "ST7789", package: "MadDrivers"),
                "MadBoardBase",
                "Sand"
            ]),
    ]
)

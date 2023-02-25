// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Core",
	platforms: [
		.iOS(.v15)
	],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "Core",
            targets: ["Core"]),
    ],
    dependencies: [
		.package(path: "../API"),
		.package(path: "../GBFoundation"),
		.package(name: "Reachability", url: "https://github.com/ashleymills/Reachability.swift", .upToNextMajor(from: "5.1.0")),
	],
    targets: [
        .target(
            name: "Core",
            dependencies: [
				.product(name: "API", package: "API"),
				.product(name: "GBFoundation", package: "GBFoundation"),
				.product(name: "Reachability", package: "Reachability")
			]
		),
        .testTarget(
            name: "CoreTests",
            dependencies: ["Core"]
		),
    ]
)

// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Components",
	platforms: [
		.iOS(.v15)
	],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "Components",
            targets: ["Components"]),
    ],
	dependencies: [
		.package(path: "../GBFoundation"),
		.package(path: "../GamebaseUI")
	],
	targets: [
		.target(
			name: "Components",
			dependencies: [
				.product(name: "GBFoundation", package: "GBFoundation"),
				.product(name: "GamebaseUI", package: "GamebaseUI")
			]
		),
        .testTarget(
            name: "ComponentsTests",
            dependencies: ["Components"]),
    ]
)

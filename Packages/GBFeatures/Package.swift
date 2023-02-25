// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "GBFeatures",
	platforms: [
		.iOS(.v15)
	],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "GBFeatures",
            targets: ["GBFeatures"]
		),
    ],
    dependencies: [
		.package(path: "../GBFoundation"),
		.package(path: "../Core"),
    ],
    targets: [
        .target(
            name: "GBFeatures",
            dependencies: [
				.product(name: "GBFoundation", package: "GBFoundation"),
				.product(name: "Core", package: "Core")
			]
		),
        .testTarget(
            name: "GBFeaturesTests",
            dependencies: ["GBFeatures"]
		),
    ]
)

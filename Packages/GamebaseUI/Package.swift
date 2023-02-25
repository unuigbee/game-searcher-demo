// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "GamebaseUI",
	platforms: [
		.iOS(.v15)
	],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "GamebaseUI",
            targets: ["GamebaseUI"]
		),
    ],
    dependencies: [
		.package(path: "../GBFoundation")
    ],
    targets: [
        .target(
            name: "GamebaseUI",
            dependencies: [
				.product(name: "GBFoundation", package: "GBFoundation"),
			]
		),
        .testTarget(
            name: "GamebaseUITests",
            dependencies: ["GamebaseUI"]
		),
    ]
)

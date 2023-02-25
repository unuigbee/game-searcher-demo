// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "GamebaseFacade",
	platforms: [
		.iOS(.v15)
	],
    products: [
        .library(
            name: "GamebaseFacade",
            targets: ["GamebaseFacade"]
		),
    ],
	dependencies: [
		.package(path: "../../../Packages/GamebaseUI"),
		.package(path: "../../../Packages/Core"),
		.package(path: "../../../Packages/Components"),
		.package(path: "../../../Packages/GBFoundation"),
		.package(path: "../../../Packages/GBFeatures")
	],
    targets: [
        .target(
            name: "GamebaseFacade",
            dependencies: [
				.product(name: "Core", package: "Core"),
				.product(name:"Components", package: "Components"),
				.product(name: "GamebaseUI", package: "GamebaseUI"),
				.product(name: "GBFoundation", package: "GBFoundation"),
				.product(name: "GBFeatures", package: "GBFeatures")
			]
		),
        .testTarget(
            name: "GamebaseFacadeTests",
            dependencies: ["GamebaseFacade"]
		),
    ]
)

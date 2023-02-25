// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "GBFoundation",
	platforms: [
		.iOS(.v15)
	],
    products: [
        .library(
            name: "GBFoundation",
            targets: ["GBFoundation", "GBFoundation.ObjC"]
		),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "GBFoundation",
            dependencies: [
				"GBFoundation.ObjC"
			],
			path: "Sources/GBFoundation"
		),
		.target(
			name: "GBFoundation.ObjC",
			dependencies: [],
			path: "Sources/GBFoundation.ObjC",
			publicHeadersPath: "CombineRuntime/include"
		),
        .testTarget(
            name: "GBFoundationTests",
            dependencies: ["GBFoundation"]
		),
    ]
)

// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "TezosSwift",
    platforms: [
        .macOS(.v10_12), .iOS(.v13)
    ],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "TezosSwift",
            targets: ["TezosSwift"]),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        .package(url: "https://github.com/Alamofire/Alamofire.git", from: "5.4.3"),
        .package(name: "Base58Swift", url: "https://github.com/mathwallet/Base58Swift.git", from: "3.0.0"),
        .package(name: "Sr25519", url: "https://github.com/lishuailibertine/Sr25519.swift.git", from: "0.1.6"),
        .package(name: "Sodium", url: "https://github.com/jedisct1/swift-sodium.git", from: "0.8.0"),
        .package(url: "https://github.com/krzyzanowskim/CryptoSwift.git", from: "1.4.1"),
        .package(name:"BIP39swift", url: "https://github.com/mathwallet/BIP39swift", from: "1.0.1"),
        .package(name: "BeaconSDK", url: "https://github.com/xueyuejie/beacon-ios-sdk.git", from: "3.1.3"),
        .package(url: "https://github.com/mxcl/PromiseKit.git", from: "6.8.4"),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "TezosSwift",
            dependencies: ["Alamofire",
                           "Base58Swift",
                           .product(name: "Ed25519", package: "Sr25519"),
                           "Sodium",
                           "CryptoSwift",
                           "BIP39swift",
                           .product(name: "BeaconBlockchainTezos", package: "BeaconSDK"),
                           .product(name: "BeaconClientWallet", package: "BeaconSDK"),
                           .product(name: "BeaconTransportP2PMatrix", package: "BeaconSDK"),
                           "PromiseKit"
                          ]),
        .testTarget(
            name: "TezosSwiftTests",
            dependencies: ["TezosSwift"]),
    ]
)

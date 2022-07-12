// swift-tools-version:5.6

// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 11/07/2022.
//  All code (c) 2022 - present day, Sam Deane.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import PackageDescription

let package = Package(
    name: "SwiftFormatterPlugin",
    platforms: [
        .macOS(.v12)
    ],
    
    products: [
        .plugin(
            name: "SwiftFormatterPlugin",
            targets: [
                "SwiftFormatterPlugin"
            ]
        ),
    ],
    
    dependencies: [
        .package(url: "https://github.com/nicklockwood/SwiftFormat", from: "0.49.11")
    ],
    
    targets: [
        .plugin(
            name: "SwiftFormatterPlugin",
        
            capability: .command(
                intent: .sourceCodeFormatting(),
                
                permissions: [
                    .writeToPackageDirectory(reason: "This command reformats source files.")
                ]
            ),
            
        
            dependencies: [
                .product(name: "swiftformat", package: "SwiftFormat"),
            ]
        ),
    ]
)

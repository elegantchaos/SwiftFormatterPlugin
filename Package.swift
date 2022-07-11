// swift-tools-version:5.7

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
    ],
    
    targets: [
        .plugin(
            name: "SwiftFormatterPlugin",
            
            capability: .command(
                intent: .custom(
                    verb: "command",
                    description: "command description"
                ),
                
                permissions: [
                    .writeToPackageDirectory(reason: "write reason")
                ]
            ),
            
            dependencies: [
            ]
        ),
    ]
)

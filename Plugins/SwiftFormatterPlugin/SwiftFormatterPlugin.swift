// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 11/07/22.
//  All code (c) 2022 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Foundation
import PackagePlugin

@main
struct FormatterPlugin: CommandPlugin {
    
    func performCommand(context: PluginContext, arguments: [String]) throws {
        let swiftFormatTool = try context.tool(named: "swiftformat")
        let swiftFormatExec = URL(fileURLWithPath: swiftFormatTool.path.string)
        //        let configFile = context.package.directory.appending(".swift-format.json")
        
        for target in context.package.targets {
            guard let target = target as? SourceModuleTarget else { continue }
            
            let process = Process()
            process.executableURL = swiftFormatExec
            process.arguments = [
                //                "--configuration", "\(configFile)",
                "--in-place",
                "--recursive",
                "\(target.directory)",
            ]
            try process.run()
            process.waitUntilExit()
            
            if process.terminationReason == .exit && process.terminationStatus == 0 {
                print("Formatted the source code in \(target.directory).")
            } else {
                let problem = "\(process.terminationReason):\(process.terminationStatus)"
                Diagnostics.error("swift-format invocation failed: \(problem)")
            }
        }
    }
}
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
        
        var baseArguments: [String] = []

        let configFile = context.package.directory.appending(".swiftformat").string
        if !FileManager.default.fileExists(atPath: configFile), let defaultPath = defaultConfigPath {
            baseArguments.append(contentsOf: ["--config", defaultPath])
        }


        for target in context.package.targets {
            guard let target = target as? SourceModuleTarget else { continue }

            var arguments = baseArguments
            arguments.append(target.directory.string)

            let process = Process()
            process.executableURL = swiftFormatExec
            process.arguments = arguments
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
    
    var defaultConfigPath: String? {
        let path = ("~/.swiftformat" as NSString).expandingTildeInPath
        if !FileManager.default.fileExists(atPath: path) {
            let defaultConfig = """
                # Place your default swift-format configuration options here.
                # See https://github.com/nicklockwood/SwiftFormat#config-file for more details.

                """
            
            do {
                try defaultConfig.write(toFile: path, atomically: true, encoding: .utf8)
            } catch {
                print(error)
                return nil
            }
        }

        return path
    }
}

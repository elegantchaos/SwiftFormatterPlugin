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
        
        let cacheFile = context.pluginWorkDirectory.appending("swift-format-cache").string
        var baseArguments: [String] = ["--quiet", "--cache", cacheFile]

        let configFile = context.package.directory.appending(".swiftformat").string
        if !FileManager.default.fileExists(atPath: configFile), let defaultPath = defaultConfigPath(workDirectory: context.pluginWorkDirectory) {
            baseArguments.append(contentsOf: ["--config", defaultPath])
        }

        let swiftVersionFile = context.package.directory.appending(".swift-version").string
        if !FileManager.default.fileExists(atPath: swiftVersionFile) {
            let tools = context.package.toolsVersion
            let version = "\(tools.major).\(tools.minor)"
            baseArguments.append(contentsOf: ["--swiftversion", version])
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
                Diagnostics.remark("Formatted the source code in \(target.directory).")
            } else {
                let problem = "\(process.terminationReason):\(process.terminationStatus)"
                Diagnostics.error("swift-format invocation failed: \(problem)")
            }
        }
    }
    
    func defaultConfigPath(workDirectory: Path) -> String? {
        let path = ("~/.swiftformat" as NSString).expandingTildeInPath
        if FileManager.default.fileExists(atPath: path) {
            return path
        }
        
        let defaultPath = workDirectory.appending("default-swift-format-config").string
        let defaultConfig = """
            # Default Elegant Chaos swift-format configuration options.
            # See https://github.com/nicklockwood/SwiftFormat#config-file for more details.
            # To override these, place a .swiftformat file into your source directory, or at ~/.swiftformat.

            --ifdef no-indent
            --indentcase true
            --self init-only
            --indentstrings true
            """
            
        do {
            try defaultConfig.write(toFile: defaultPath, atomically: true, encoding: .utf8)
            return defaultPath
        } catch {
            print(error)
            return nil
        }
    }
}

#if canImport(XcodeProjectPlugin)
import XcodeProjectPlugin

extension FormatterPlugin: XcodeCommandPlugin {
    func performCommand(context: XcodePluginContext, arguments: [String]) throws {
        let swiftFormatTool = try context.tool(named: "swiftformat")
        let swiftFormatExec = URL(fileURLWithPath: swiftFormatTool.path.string)
        
        let cacheFile = context.pluginWorkDirectory.appending("swift-format-cache").string
        var baseArguments: [String] = ["--quiet", "--cache", cacheFile]
        
        let configFile = context.xcodeProject.directory.appending(".swiftformat").string
        if !FileManager.default.fileExists(atPath: configFile), let defaultPath = defaultConfigPath(workDirectory: context.pluginWorkDirectory) {
            baseArguments.append(contentsOf: ["--config", defaultPath])
        }
        
//        let swiftVersionFile = context.xcodeProject.directory.appending(".swift-version").string
//        if !FileManager.default.fileExists(atPath: swiftVersionFile) {
//            let tools = context.xcodeProject.
//            let version = "\(tools.major).\(tools.minor)"
//            baseArguments.append(contentsOf: ["--swiftversion", version])
//        }
        
        var arguments = baseArguments
        let path = context.xcodeProject.directory.string
        arguments.append(path)
        
        let process = Process()
        process.executableURL = swiftFormatExec
        process.arguments = arguments
        try process.run()
        process.waitUntilExit()
        
        if process.terminationReason == .exit && process.terminationStatus == 0 {
            Diagnostics.remark("Formatted the source code in \(path).")
        } else {
            let problem = "\(process.terminationReason):\(process.terminationStatus)"
            Diagnostics.error("swift-format invocation failed: \(problem)")
        }
    }
}
#endif

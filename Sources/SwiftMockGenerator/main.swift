import Foundation
import ArgumentParser
import SwiftMockGeneratorLib

@main
struct SwiftMockGenerator: AsyncParsableCommand {
    static var configuration = CommandConfiguration(
        commandName: "swift-mock-generator",
        abstract: "Generate Swift mocks from annotated source code",
        discussion: """
        This tool scans Swift source files for special comments like // @Stub, // @Spy, // @Dummy
        and generates corresponding mock implementations.
        
        Supported annotations:
        - // @Stub - Creates a stub implementation with default return values
        - // @Spy - Creates a spy that records method calls and parameters
        - // @Dummy - Creates a dummy implementation that does nothing
        
        The tool automatically detects the module name from Package.swift or Xcode project files
        and adds @testable import statements to generated mock files.
        
        Example usage:
        swift-mock-generator --input ./Sources --output ./Tests/Mocks
        swift-mock-generator --input ./Sources --output ./Tests/Mocks --module MyApp
        """
    )
    
    @Option(name: .shortAndLong, help: "Input directory containing Swift source files")
    var input: String = "."
    
    @Option(name: .shortAndLong, help: "Output directory for generated mock files")
    var output: String = "./Mocks"
    
    @Flag(name: .shortAndLong, help: "Enable verbose logging")
    var verbose: Bool = false
    
    @Flag(help: "Clean output directory before generating mocks")
    var clean: Bool = false
    
    @Option(name: .shortAndLong, help: "Module name for @testable import (auto-detected if not provided)")
    var module: String?
    
    mutating func run() async throws {
        let generator = MockGenerator(
            inputPath: input,
            outputPath: output,
            verbose: verbose,
            moduleName: module
        )
        
        if clean {
            try generator.cleanOutputDirectory()
        }
        
        try await generator.generateMocks()
        
        print("✅ Mock generation completed successfully!")
    }
}

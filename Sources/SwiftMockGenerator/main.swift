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
        
        Example usage:
        swift-mock-generator --input ./Sources --output ./Tests/Mocks
        """
    )
    
    @Option(name: .shortAndLong, help: "Input directory containing Swift source files")
    var input: String = "."
    
    @Option(name: .shortAndLong, help: "Output directory for generated mock files")
    var output: String = "./Mocks"
    
    @Option(help: "File pattern to match Swift files")
    var pattern: String = "*.swift"
    
    @Flag(name: .shortAndLong, help: "Enable verbose logging")
    var verbose: Bool = false
    
    @Flag(help: "Clean output directory before generating mocks")
    var clean: Bool = false
    
    mutating func run() async throws {
        let generator = MockGenerator(
            inputPath: input,
            outputPath: output,
            filePattern: pattern,
            verbose: verbose
        )
        
        if clean {
            try generator.cleanOutputDirectory()
        }
        
        try await generator.generateMocks()
        
        print("✅ Mock generation completed successfully!")
    }
}

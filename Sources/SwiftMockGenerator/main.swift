import ArgumentParser
import Foundation
import SwiftSyntax
import SwiftParser

@main
struct SwiftMockGenerator: ParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "swift-mock-generator",
        abstract: "A Swift tool for generating mocks from annotated source code",
        discussion: """
        This tool parses Swift source files and generates mock objects based on special comments:
        - // @Stub - Creates a stub implementation
        - // @Spy - Creates a spy that tracks method calls
        - // @Dummy - Creates a minimal dummy implementation
        
        Supports classes, protocols, enums, and various function types including async and throwing functions.
        """
    )
    
    @Argument(help: "Swift source files to process")
    var inputFiles: [String] = []
    
    @Option(name: .shortAndLong, help: "Output directory for generated mocks")
    var output: String = "Generated"
    
    @Flag(name: .shortAndLong, help: "Enable verbose output")
    var verbose: Bool = false
    
    func run() throws {
        if inputFiles.isEmpty {
            print("Error: No input files specified")
            throw ExitCode.failure
        }
        
        let generator = MockGenerator(outputDirectory: output, verbose: verbose)
        
        for inputFile in inputFiles {
            if verbose {
                print("Processing file: \(inputFile)")
            }
            
            try generator.processFile(at: inputFile)
        }
        
        print("Mock generation completed successfully!")
    }
}
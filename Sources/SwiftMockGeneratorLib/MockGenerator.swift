import Foundation
import SwiftSyntax
import SwiftParser

/// Main class responsible for generating mocks from annotated Swift source files
public class MockGenerator {
    private let inputPath: String
    private let outputPath: String
    private let filePattern: String
    private let verbose: Bool
    
    private let fileManager = FileManager.default
    private let syntaxParser = SyntaxParser()
    private let stubGenerator = StubGenerator()
    private let spyGenerator = SpyGenerator()
    private let dummyGenerator = DummyGenerator()
    
    public init(inputPath: String, outputPath: String, filePattern: String, verbose: Bool = false) {
        self.inputPath = inputPath
        self.outputPath = outputPath
        self.filePattern = filePattern
        self.verbose = verbose
    }
    
    /// Clean the output directory before generating new mocks
    public func cleanOutputDirectory() throws {
        if fileManager.fileExists(atPath: outputPath) {
            try fileManager.removeItem(atPath: outputPath)
            log("🗑️ Cleaned output directory: \(outputPath)")
        }
    }
    
    /// Generate mocks for all annotated Swift files
    public func generateMocks() async throws {
        // Create output directory if it doesn't exist
        try createOutputDirectoryIfNeeded()
        
        // Find all Swift files
        let swiftFiles = try findSwiftFiles()
        log("📁 Found \(swiftFiles.count) Swift files to process")
        
        // Process each file
        for filePath in swiftFiles {
            try await processFile(filePath)
        }
    }
    
    // MARK: - Private Methods
    
    private func createOutputDirectoryIfNeeded() throws {
        if !fileManager.fileExists(atPath: outputPath) {
            try fileManager.createDirectory(atPath: outputPath, withIntermediateDirectories: true)
            log("📁 Created output directory: \(outputPath)")
        }
    }
    
    private func findSwiftFiles() throws -> [String] {
        guard let enumerator = fileManager.enumerator(atPath: inputPath) else {
            throw MockGeneratorError.invalidInputPath(inputPath)
        }
        
        var swiftFiles: [String] = []
        
        for case let fileName as String in enumerator {
            if fileName.hasSuffix(".swift") && !fileName.contains("/.") {
                let fullPath = (inputPath as NSString).appendingPathComponent(fileName)
                swiftFiles.append(fullPath)
            }
        }
        
        return swiftFiles
    }
    
    private func processFile(_ filePath: String) async throws {
        log("🔍 Processing file: \(filePath)")
        
        // Read file content
        let content = try String(contentsOfFile: filePath)
        
        // Parse Swift syntax and find annotations
        let annotations = syntaxParser.parseAnnotations(from: content, filePath: filePath)
        
        // Generate mocks for each annotation
        for annotation in annotations {
            try await generateMock(for: annotation, originalFile: filePath)
        }
    }
    
    private func generateMock(for annotation: MockAnnotation, originalFile: String) async throws {
        let generator: MockGeneratorProtocol
        
        switch annotation.type {
        case .stub:
            generator = stubGenerator
        case .spy:
            generator = spyGenerator
        case .dummy:
            generator = dummyGenerator
        }
        
        let mockCode = try generator.generateMock(for: annotation.element, annotation: annotation)
        
        // Write to output file
        let outputFile = createOutputFileName(for: annotation, originalFile: originalFile)
        let outputFilePath = (outputPath as NSString).appendingPathComponent(outputFile)
        
        try mockCode.write(toFile: outputFilePath, atomically: true, encoding: .utf8)
        log("✏️ Generated \(annotation.type.rawValue) mock: \(outputFile)")
    }
    
    private func createOutputFileName(for annotation: MockAnnotation, originalFile: String) -> String {
        let originalFileName = (originalFile as NSString).lastPathComponent
        let nameWithoutExtension = (originalFileName as NSString).deletingPathExtension
        let elementName = annotation.element.name
        return "\(nameWithoutExtension)_\(elementName)_\(annotation.type.rawValue).swift"
    }
    
    private func log(_ message: String) {
        if verbose {
            print(message)
        }
    }
}

// MARK: - Error Types

public enum MockGeneratorError: LocalizedError {
    case invalidInputPath(String)
    case fileProcessingError(String, Error)
    case mockGenerationError(String)
    
    public var errorDescription: String? {
        switch self {
        case .invalidInputPath(let path):
            return "Invalid input path: \(path)"
        case .fileProcessingError(let file, let error):
            return "Error processing file \(file): \(error.localizedDescription)"
        case .mockGenerationError(let message):
            return "Mock generation error: \(message)"
        }
    }
}

import Foundation
import SwiftSyntax
import SwiftParser

/// Main class responsible for parsing Swift files and generating mocks
class MockGenerator {
    private let outputDirectory: String
    private let verbose: Bool
    private let fileManager = FileManager.default
    
    init(outputDirectory: String, verbose: Bool = false) {
        self.outputDirectory = outputDirectory
        self.verbose = verbose
    }
    
    /// Process a single Swift file and generate mocks for annotated declarations
    func processFile(at path: String) throws {
        guard fileManager.fileExists(atPath: path) else {
            throw MockGeneratorError.fileNotFound(path)
        }
        
        let sourceCode = try String(contentsOfFile: path)
        let sourceFile = Parser.parse(source: sourceCode)
        
        let visitor = MockAnnotationVisitor()
        visitor.walk(sourceFile)
        
        for annotation in visitor.annotations {
            if verbose {
                print("Found \(annotation.mockType) annotation for \(annotation.declaration.kind)")
            }
            
            try generateMock(for: annotation, sourceFile: sourceFile, originalPath: path)
        }
    }
    
    /// Generate mock code based on the annotation and declaration
    private func generateMock(for annotation: MockAnnotation, sourceFile: SourceFileSyntax, originalPath: String) throws {
        let generator: MockCodeGenerator
        
        switch annotation.mockType {
        case .stub:
            generator = StubGenerator()
        case .spy:
            generator = SpyGenerator()
        case .dummy:
            generator = DummyGenerator()
        }
        
        let mockCode = try generator.generateMock(
            for: annotation.declaration,
            in: sourceFile,
            originalPath: originalPath
        )
        
        try saveMockCode(mockCode, for: annotation, originalPath: originalPath)
    }
    
    /// Save generated mock code to appropriate file
    private func saveMockCode(_ code: String, for annotation: MockAnnotation, originalPath: String) throws {
        // Create output directory if it doesn't exist
        try fileManager.createDirectory(atPath: outputDirectory, withIntermediateDirectories: true, attributes: nil)
        
        let originalFileName = URL(fileURLWithPath: originalPath).deletingPathExtension().lastPathComponent
        let mockFileName = "\(originalFileName)_\(annotation.mockType.rawValue)_\(annotation.declarationName).swift"
        let mockFilePath = "\(outputDirectory)/\(mockFileName)"
        
        try code.write(toFile: mockFilePath, atomically: true, encoding: .utf8)
        
        if verbose {
            print("Generated mock: \(mockFilePath)")
        }
    }
}

/// Errors that can occur during mock generation
enum MockGeneratorError: Error, LocalizedError {
    case fileNotFound(String)
    case unsupportedDeclaration(String)
    case invalidAnnotation(String)
    
    var errorDescription: String? {
        switch self {
        case .fileNotFound(let path):
            return "File not found: \(path)"
        case .unsupportedDeclaration(let type):
            return "Unsupported declaration type: \(type)"
        case .invalidAnnotation(let annotation):
            return "Invalid annotation: \(annotation)"
        }
    }
}
import Foundation
import SwiftSyntax
import SwiftParser

/// Main class responsible for generating mocks from annotated Swift source files
public class MockGenerator {
    private let inputPath: String
    private let outputPath: String
    private let verbose: Bool
    private let moduleName: String?
    private let useResult: Bool
    
    private let fileManager = FileManager.default
    private let syntaxParser = SyntaxParser()
    private let stubGenerator = StubGenerator()
    private let spyGenerator = SpyGenerator()
    private let dummyGenerator = DummyGenerator()
    
    public init(inputPath: String, outputPath: String, verbose: Bool = false, moduleName: String? = nil, useResult: Bool = false) {
        self.inputPath = inputPath
        self.outputPath = outputPath
        self.verbose = verbose
        self.moduleName = moduleName
        self.useResult = useResult
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
    
    internal func generateMock(for annotation: MockAnnotation, originalFile: String) async throws {
        let generator: MockGeneratorProtocol

        // Debug logging
        log("🔍 Processing annotation: \(annotation.type.rawValue) for element: \(annotation.element.name)")

        switch annotation.type {
        case .stub:
            generator = stubGenerator
        case .spy:
            generator = spyGenerator
        case .dummy:
            generator = dummyGenerator
        }
        
        // Generate each part separately
        let header = generateHeader(for: annotation)
        let testableImport = generateTestableImport()
        let mockDefinition = try generator.generateMockDefinition(for: annotation.element, annotation: annotation, useResult: useResult)
        
        // Combine all parts
        let finalMockCode = combineMockParts(header: header, testableImport: testableImport, mockDefinition: mockDefinition)
        
        // Debug logging
        log("📝 Generated mock code length: \(finalMockCode.count) characters")
        
        // Write to output file
        let outputFile = createOutputFileName(for: annotation, originalFile: originalFile)
        let outputFilePath = (outputPath as NSString).appendingPathComponent(outputFile)
        
        try finalMockCode.write(toFile: outputFilePath, atomically: true, encoding: .utf8)
        log("✏️ Generated \(annotation.type.rawValue) mock: \(outputFile)")
    }
    
    internal func createOutputFileName(for annotation: MockAnnotation, originalFile: String) -> String {
        let elementName = annotation.element.name
        let mockTypeSuffix = annotation.type.rawValue
        return "\(elementName)\(mockTypeSuffix).swift"
    }
    
    private func log(_ message: String) {
        if verbose {
            print(message)
        }
    }
    
    // MARK: - Test Helper Methods
    
    /// Helper method for tests to generate mock code with @testable import
    internal func generateMockCode(for element: CodeElement, annotation: MockAnnotation) throws -> String {
        // Generate each part separately
        let header = generateHeader(for: annotation)
        let testableImport = generateTestableImport()
        let mockDefinition = try getGenerator(for: annotation.type).generateMockDefinition(for: element, annotation: annotation, useResult: useResult)
        
        // Combine all parts
        return combineMockParts(header: header, testableImport: testableImport, mockDefinition: mockDefinition)
    }
    
    private func getGenerator(for type: MockType) -> MockGeneratorProtocol {
        switch type {
        case .stub:
            return stubGenerator
        case .spy:
            return spyGenerator
        case .dummy:
            return dummyGenerator
        }
    }
    
    // MARK: - Module Detection and @testable import
    
    private func generateHeader(for annotation: MockAnnotation) -> String {
        let fileName = createOutputFileName(for: annotation, originalFile: "")
        return """
        // \(fileName)
        // \(annotation.type.rawValue.capitalized) generated for \(annotation.element.name)
        // Generated by SwiftMockGenerator
        """
    }
    
    private func generateTestableImport() -> String? {
        guard let moduleName = detectModuleName() else {
            return nil
        }
        return "@testable import \(moduleName)"
    }
    
    private func combineMockParts(header: String, testableImport: String?, mockDefinition: String) -> String {
        var parts = [header]
        
        if let testableImport = testableImport {
            parts.append("")
            parts.append(testableImport)
        }
        
        parts.append(mockDefinition)
        
        return parts.joined(separator: "\n")
    }
    
    internal func detectModuleName() -> String? {
        // If module name was provided explicitly, use it
        if let providedModule = moduleName {
            return providedModule
        }
        
        // Try to detect from Swift Package
        if let packageModule = detectSwiftPackageModule() {
            return packageModule
        }
        
        // Try to detect from Xcode project
        if let xcodeModule = detectXcodeProjectModule() {
            return xcodeModule
        }
        
        return nil
    }
    
    private func detectSwiftPackageModule() -> String? {
        let packageSwiftPath = findPackageSwiftFile()
        guard let packagePath = packageSwiftPath else { return nil }
        
        do {
            let content = try String(contentsOfFile: packagePath)
            // Parse Package.swift to find the package name
            // Look for: name: "PackageName"
            let lines = content.components(separatedBy: .newlines)
            for line in lines {
                let trimmedLine = line.trimmingCharacters(in: .whitespacesAndNewlines)
                if trimmedLine.hasPrefix("name:") {
                    // Extract name from: name: "PackageName"
                    let components = trimmedLine.components(separatedBy: ":")
                    if components.count >= 2 {
                        let namePart = components[1].trimmingCharacters(in: .whitespacesAndNewlines)
                        // Remove quotes and trailing comma
                        let moduleName = namePart.replacingOccurrences(of: "\"", with: "").replacingOccurrences(of: ",", with: "")
                        log("📦 Detected Swift Package module: \(moduleName)")
                        return moduleName
                    }
                }
            }
        } catch {
            log("⚠️ Could not read Package.swift: \(error)")
        }
        
        return nil
    }
    
    private func detectXcodeProjectModule() -> String? {
        // Look for .xcodeproj or .xcworkspace files
        let projectFiles = findXcodeProjectFiles()
        guard !projectFiles.isEmpty else { return nil }
        
        // Extract module name from the project file path
        // For .xcodeproj files, the module name is the directory name without .xcodeproj
        for projectFile in projectFiles {
            let projectURL = URL(fileURLWithPath: projectFile)
            let projectName = projectURL.lastPathComponent
            
            if projectName.hasSuffix(".xcodeproj") {
                let moduleName = String(projectName.dropLast(".xcodeproj".count))
                log("📱 Detected Xcode project module: \(moduleName)")
                return moduleName
            } else if projectName.hasSuffix(".xcworkspace") {
                let moduleName = String(projectName.dropLast(".xcworkspace".count))
                log("📱 Detected Xcode workspace module: \(moduleName)")
                return moduleName
            }
        }
        
        return nil
    }
    
    private func findPackageSwiftFile() -> String? {
        var currentPath = inputPath
        
        // Search up the directory tree for Package.swift
        while !currentPath.isEmpty && currentPath != "/" {
            let packagePath = (currentPath as NSString).appendingPathComponent("Package.swift")
            if fileManager.fileExists(atPath: packagePath) {
                return packagePath
            }
            currentPath = (currentPath as NSString).deletingLastPathComponent
        }
        
        return nil
    }
    
    internal func findXcodeProjectFiles() -> [String] {
        var projectFiles: [String] = []
        
        guard let enumerator = fileManager.enumerator(atPath: inputPath) else {
            return projectFiles
        }
        
        for case let fileName as String in enumerator {
            if fileName.hasSuffix(".xcodeproj") || fileName.hasSuffix(".xcworkspace") {
                let fullPath = (inputPath as NSString).appendingPathComponent(fileName)
                projectFiles.append(fullPath)
            }
        }
        
        return projectFiles
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

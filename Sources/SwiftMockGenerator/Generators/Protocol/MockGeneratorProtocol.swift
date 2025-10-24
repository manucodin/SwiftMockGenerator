import Foundation

// MARK: - Mock Generator Protocol

/// Protocol for different types of mock generators
public protocol MockGeneratorProtocol {
    func generateMock(for element: CodeElement, annotation: MockAnnotation, useResult: Bool) throws -> String
    func generateMockDefinition(for element: CodeElement, annotation: MockAnnotation, useResult: Bool) throws -> String
}
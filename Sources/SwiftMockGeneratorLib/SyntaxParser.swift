import Foundation
import SwiftSyntax
import SwiftParser

/// Parser responsible for analyzing Swift syntax and extracting mock annotations
public class SyntaxParser {
    public init() {}
    
    /// Parse a Swift source file and return annotations
    public func parseAnnotations(from source: String, filePath: String) -> [MockAnnotation] {
        let sourceFile = SwiftParser.Parser.parse(source: source)
        let visitor = AnnotationVisitor(filePath: filePath, sourceText: source)
        visitor.walk(sourceFile)
        return visitor.annotations
    }
}

/// Visitor that walks the syntax tree and finds annotated elements
public class AnnotationVisitor: SyntaxVisitor {
    private let filePath: String
    private let sourceLines: [String]
    private(set) var annotations: [MockAnnotation] = []
    
    public init(filePath: String, sourceText: String) {
        self.filePath = filePath
        self.sourceLines = sourceText.components(separatedBy: .newlines)
        super.init(viewMode: .sourceAccurate)
    }
    
    // MARK: - Protocol Declarations
    
    public override func visit(_ node: ProtocolDeclSyntax) -> SyntaxVisitorContinueKind {
        if let annotation = extractAnnotation(for: node) {
            let protocolElement = parseProtocolElement(from: node)
            let mockAnnotation = MockAnnotation(
                type: annotation.type,
                element: .protocol(protocolElement),
                location: createSourceLocation(for: node),
                options: annotation.options
            )
            annotations.append(mockAnnotation)
        }
        return .visitChildren
    }
    
    // MARK: - Class Declarations
    
    public override func visit(_ node: ClassDeclSyntax) -> SyntaxVisitorContinueKind {
        if let annotation = extractAnnotation(for: node) {
            let classElement = parseClassElement(from: node)
            let mockAnnotation = MockAnnotation(
                type: annotation.type,
                element: .class(classElement),
                location: createSourceLocation(for: node),
                options: annotation.options
            )
            annotations.append(mockAnnotation)
        }
        return .visitChildren
    }
    
    // MARK: - Struct Declarations
    
    public override func visit(_ node: StructDeclSyntax) -> SyntaxVisitorContinueKind {
        if let annotation = extractAnnotation(for: node) {
            let structElement = parseStructElement(from: node)
            let mockAnnotation = MockAnnotation(
                type: annotation.type,
                element: .struct(structElement),
                location: createSourceLocation(for: node),
                options: annotation.options
            )
            annotations.append(mockAnnotation)
        }
        return .visitChildren
    }
    
    // MARK: - Function Declarations
    
    public override func visit(_ node: FunctionDeclSyntax) -> SyntaxVisitorContinueKind {
        if let annotation = extractAnnotation(for: node) {
            let functionElement = parseFunctionElement(from: node)
            let mockAnnotation = MockAnnotation(
                type: annotation.type,
                element: .function(functionElement),
                location: createSourceLocation(for: node),
                options: annotation.options
            )
            annotations.append(mockAnnotation)
        }
        return .visitChildren
    }
    
    // MARK: - Private Parsing Methods
    
    private func extractAnnotation(for node: SyntaxProtocol) -> (type: MockType, options: [String: String])? {
        // Simple approach: check a few lines above the node for annotation
        // In a real implementation, we might want to use trivia or more sophisticated parsing
        let currentLine = getCurrentLine(for: node)
        
        // Look for annotation in the preceding lines (typically 1-3 lines above)
        for i in stride(from: max(0, currentLine - 3), to: currentLine, by: 1) {
            if i < sourceLines.count, let annotation = parseAnnotationComment(sourceLines[i]) {
                return annotation
            }
        }
        
        return nil
    }
    
    private func getCurrentLine(for node: SyntaxProtocol) -> Int {
        // Simple approximation - in a real implementation you'd use the converter
        return Int(node.position.utf8Offset / 50) // Very rough estimate
    }
    
    private func parseAnnotationComment(_ line: String) -> (type: MockType, options: [String: String])? {
        let trimmedLine = line.trimmingCharacters(in: .whitespaces)
        
        for mockType in MockType.allCases {
            if trimmedLine.hasPrefix(mockType.commentPrefix) {
                let optionsString = String(trimmedLine.dropFirst(mockType.commentPrefix.count))
                let options = parseAnnotationOptions(optionsString)
                return (type: mockType, options: options)
            }
        }
        
        return nil
    }
    
    private func parseAnnotationOptions(_ optionsString: String) -> [String: String] {
        let trimmed = optionsString.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty, trimmed.hasPrefix("("), trimmed.hasSuffix(")") else {
            return [:]
        }
        
        let content = String(trimmed.dropFirst().dropLast())
        var options: [String: String] = [:]
        
        let components = content.components(separatedBy: ",")
        for component in components {
            let keyValue = component.components(separatedBy: ":")
            if keyValue.count == 2 {
                let key = keyValue[0].trimmingCharacters(in: .whitespaces)
                let value = keyValue[1].trimmingCharacters(in: .whitespaces)
                options[key] = value
            }
        }
        
        return options
    }
    
    private func createSourceLocation(for node: SyntaxProtocol) -> SourceLocation {
        // Simple implementation - in practice you'd use SourceLocationConverter
        return SourceLocation(line: 1, column: 1, file: filePath)
    }
    
    // MARK: - Element Parsing (Simplified)
    
    private func parseProtocolElement(from node: ProtocolDeclSyntax) -> ProtocolElement {
        let name = node.name.text
        let accessLevel = parseAccessLevel(from: node.modifiers)
        let inheritance = parseInheritanceClause(node.inheritanceClause)
        
        // For now, return a simple protocol element
        // In a full implementation, you'd parse all members
        return ProtocolElement(
            name: name,
            methods: [],
            properties: [],
            associatedTypes: [],
            inheritance: inheritance,
            accessLevel: accessLevel,
            genericParameters: []
        )
    }
    
    private func parseClassElement(from node: ClassDeclSyntax) -> ClassElement {
        let name = node.name.text
        let accessLevel = parseAccessLevel(from: node.modifiers)
        let inheritance = parseInheritanceClause(node.inheritanceClause)
        
        return ClassElement(
            name: name,
            methods: [],
            properties: [],
            initializers: [],
            inheritance: inheritance,
            accessLevel: accessLevel,
            genericParameters: [],
            isFinal: false
        )
    }
    
    private func parseStructElement(from node: StructDeclSyntax) -> StructElement {
        let name = node.name.text
        let accessLevel = parseAccessLevel(from: node.modifiers)
        let inheritance = parseInheritanceClause(node.inheritanceClause)
        
        return StructElement(
            name: name,
            methods: [],
            properties: [],
            initializers: [],
            inheritance: inheritance,
            accessLevel: accessLevel,
            genericParameters: []
        )
    }
    
    private func parseFunctionElement(from node: FunctionDeclSyntax) -> FunctionElement {
        let name = node.name.text
        let accessLevel = parseAccessLevel(from: node.modifiers)
        let parameters = parseParameterClause(node.signature.parameterClause)
        let returnType = parseReturnClause(node.signature.returnClause)
        
        return FunctionElement(
            name: name,
            parameters: parameters,
            returnType: returnType,
            accessLevel: accessLevel,
            isStatic: false,
            isAsync: false,
            isThrowing: false,
            genericParameters: []
        )
    }
    
    // MARK: - Helper Parsing Methods
    
    private func parseAccessLevel(from modifiers: DeclModifierListSyntax) -> AccessLevel {
        for modifier in modifiers {
            if let accessLevel = AccessLevel(rawValue: modifier.name.text) {
                return accessLevel
            }
        }
        return .internal
    }
    
    private func parseInheritanceClause(_ clause: InheritanceClauseSyntax?) -> [String] {
        guard let clause = clause else { return [] }
        
        return clause.inheritedTypes.map { inheritedType in
            inheritedType.type.description.trimmingCharacters(in: .whitespaces)
        }
    }
    
    private func parseParameterClause(_ clause: FunctionParameterClauseSyntax) -> [ParameterElement] {
        return clause.parameters.map { parameter in
            let externalName = parameter.firstName.text
            let internalName = parameter.secondName?.text ?? parameter.firstName.text
            let type = parameter.type.description.trimmingCharacters(in: .whitespaces)
            
            return ParameterElement(
                externalName: externalName == internalName ? nil : externalName,
                internalName: internalName,
                type: type,
                defaultValue: nil,
                isInout: false,
                isVariadic: false
            )
        }
    }
    
    private func parseReturnClause(_ clause: ReturnClauseSyntax?) -> String? {
        guard let clause = clause else { return nil }
        return clause.type.description.trimmingCharacters(in: .whitespaces)
    }
}
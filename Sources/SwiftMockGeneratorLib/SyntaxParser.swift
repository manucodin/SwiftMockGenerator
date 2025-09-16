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
    private let sourceText: String
    private let sourceLocationConverter: SourceLocationConverter
    private(set) var annotations: [MockAnnotation] = []
    
    public init(filePath: String, sourceText: String) {
        self.filePath = filePath
        self.sourceText = sourceText
        self.sourceLines = sourceText.components(separatedBy: .newlines)
        
        // Create source file for accurate line/column conversion
        let sourceFile = SwiftParser.Parser.parse(source: sourceText)
        self.sourceLocationConverter = SourceLocationConverter(fileName: filePath, tree: sourceFile)
        
        super.init(viewMode: .sourceAccurate)
    }
    
    // MARK: - Protocol Declarations
    
    public override func visit(_ node: ProtocolDeclSyntax) -> SyntaxVisitorContinueKind {
        if let annotation = extractAnnotation(for: node) {
            let protocolElement = parseProtocolElement(from: node)
            let mockAnnotation = MockAnnotation(
                type: annotation,
                element: .protocol(protocolElement),
                location: createSourceLocation(for: node)
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
                type: annotation,
                element: .class(classElement),
                location: createSourceLocation(for: node)
            )
            annotations.append(mockAnnotation)
        }
        return .visitChildren
    }
    
    // MARK: - Struct Declarations
    
    public override func visit(_ node: StructDeclSyntax) -> SyntaxVisitorContinueKind {
        // Skip struct declarations - structs are value types and generally don't need mocks
        // Use the actual struct instance in tests instead
        return .visitChildren
    }
    
    // MARK: - Function Declarations
    
    public override func visit(_ node: FunctionDeclSyntax) -> SyntaxVisitorContinueKind {
        // Only process standalone functions (not those inside protocols/classes/structs)
        // Functions inside protocols/classes/structs are handled by their respective parsers
        if isStandaloneFunction(node) {
            if let annotation = extractAnnotation(for: node) {
                let functionElement = parseFunctionElement(from: node)
                let mockAnnotation = MockAnnotation(
                    type: annotation,
                    element: .function(functionElement),
                    location: createSourceLocation(for: node)
                )
                annotations.append(mockAnnotation)
            }
        }
        return .visitChildren
    }
    
    // MARK: - Private Parsing Methods
    
    private func extractAnnotation(for node: SyntaxProtocol) -> MockType? {
        // Get the declaration keyword to find the actual line
        var searchText = ""
        if let protocolDecl = node.as(ProtocolDeclSyntax.self) {
            searchText = "protocol \(protocolDecl.name.text)"
        } else if let classDecl = node.as(ClassDeclSyntax.self) {
            searchText = "class \(classDecl.name.text)"
        } else if let funcDecl = node.as(FunctionDeclSyntax.self) {
            searchText = "func \(funcDecl.name.text)"
        }
        
        if searchText.isEmpty {
            return nil
        }
        
        // Find the line containing this declaration
        var declarationLine = -1
        for (index, line) in sourceLines.enumerated() {
            if line.contains(searchText) {
                declarationLine = index + 1 // Convert to 1-based
                break
            }
        }
        
        if declarationLine == -1 {
            return nil
        }
        
        // Look for annotation in the preceding lines (up to 10 lines above to handle file headers)
        let searchStartLine = max(1, declarationLine - 10)
        for lineNumber in stride(from: declarationLine - 1, through: searchStartLine, by: -1) {
            let arrayIndex = lineNumber - 1 // Convert to 0-based array index
            if arrayIndex >= 0 && arrayIndex < sourceLines.count {
                let line = sourceLines[arrayIndex]
                
                if let annotationType = parseAnnotationComment(line) {
                    return annotationType
                }
                
                // If we encounter a non-empty line that's not a comment or annotation,
                // stop searching (this prevents finding annotations from previous elements)
                let trimmedLine = line.trimmingCharacters(in: .whitespaces)
                if !trimmedLine.isEmpty && !trimmedLine.hasPrefix("//") && !trimmedLine.hasPrefix("/*") {
                    break
                }
            }
        }
        return nil
    }
    
    private func parseAnnotationComment(_ line: String) -> MockType? {
        let trimmedLine = line.trimmingCharacters(in: .whitespaces)
        
        // Handle both single-line and multi-line comment formats
        var commentContent = ""
        if trimmedLine.hasPrefix("//") {
            commentContent = String(trimmedLine.dropFirst(2)).trimmingCharacters(in: .whitespaces)
        } else if trimmedLine.hasPrefix("/*") && trimmedLine.hasSuffix("*/") {
            let withoutPrefix = String(trimmedLine.dropFirst(2))
            commentContent = String(withoutPrefix.dropLast(2)).trimmingCharacters(in: .whitespaces)
        } else {
            return nil
        }
        
        // Check for mock type annotations
        for mockType in MockType.allCases {
            let annotationPattern = "@\(mockType.rawValue)"
            if commentContent.hasPrefix(annotationPattern) {
                return mockType
            }
        }
        
        return nil
    }
    
    
    private func createSourceLocation(for node: SyntaxProtocol) -> SourceLocation {
        let location = sourceLocationConverter.location(for: node.position)
        return SourceLocation(line: location.line, column: location.column, file: filePath)
    }
    
    // MARK: - Element Parsing (Full Implementation)
    
    private func parseProtocolElement(from node: ProtocolDeclSyntax) -> ProtocolElement {
        let name = node.name.text
        let accessLevel = parseAccessLevel(from: node.modifiers)
        let inheritance = parseInheritanceClause(node.inheritanceClause)
        let genericParameters: [String] = [] // TODO: Parse generic parameters properly
        
        // Parse protocol members
        var methods: [MethodElement] = []
        var properties: [PropertyElement] = []
        var associatedTypes: [AssociatedTypeElement] = []
        
        let members = node.memberBlock.members
        for member in members {
            if let functionDecl = member.decl.as(FunctionDeclSyntax.self) {
                let method = parseMethodElement(from: functionDecl)
                methods.append(method)
            } else if let varDecl = member.decl.as(VariableDeclSyntax.self) {
                let parsedProperties = parsePropertyElements(from: varDecl)
                properties.append(contentsOf: parsedProperties)
            } else if let associatedTypeDecl = member.decl.as(AssociatedTypeDeclSyntax.self) {
                let associatedType = parseAssociatedTypeElement(from: associatedTypeDecl)
                associatedTypes.append(associatedType)
            }
        }
        
        return ProtocolElement(
            name: name,
            methods: methods,
            properties: properties,
            associatedTypes: associatedTypes,
            inheritance: inheritance,
            accessLevel: accessLevel,
            genericParameters: genericParameters
        )
    }
    
    private func parseClassElement(from node: ClassDeclSyntax) -> ClassElement {
        let name = node.name.text
        let accessLevel = parseAccessLevel(from: node.modifiers)
        let inheritance = parseInheritanceClause(node.inheritanceClause)
        let genericParameters: [String] = [] // TODO: Parse generic parameters properly
        let isFinal = node.modifiers.contains { $0.name.text == "final" }
        
        // Parse class members
        var methods: [MethodElement] = []
        var properties: [PropertyElement] = []
        var initializers: [InitializerElement] = []
        
        let members = node.memberBlock.members
        for member in members {
            if let functionDecl = member.decl.as(FunctionDeclSyntax.self) {
                let method = parseMethodElement(from: functionDecl)
                methods.append(method)
            } else if let varDecl = member.decl.as(VariableDeclSyntax.self) {
                let parsedProperties = parsePropertyElements(from: varDecl)
                properties.append(contentsOf: parsedProperties)
            } else if let initDecl = member.decl.as(InitializerDeclSyntax.self) {
                let initializer = parseInitializerElement(from: initDecl)
                initializers.append(initializer)
            }
        }
        
        return ClassElement(
            name: name,
            methods: methods,
            properties: properties,
            initializers: initializers,
            inheritance: inheritance,
            accessLevel: accessLevel,
            genericParameters: genericParameters,
            isFinal: isFinal
        )
    }
    
    
    private func parseFunctionElement(from node: FunctionDeclSyntax) -> FunctionElement {
        let name = node.name.text
        let accessLevel = parseAccessLevel(from: node.modifiers)
        let parameters = parseParameterClause(node.signature.parameterClause)
        let returnType = parseReturnClause(node.signature.returnClause)
        let isStatic = node.modifiers.contains { $0.name.text == "static" }
        let isAsync = node.signature.effectSpecifiers?.asyncSpecifier != nil
        let isThrowing = node.signature.effectSpecifiers?.throwsSpecifier != nil
        let genericParameters: [String] = [] // TODO: Parse generic parameters properly
        
        return FunctionElement(
            name: name,
            parameters: parameters,
            returnType: returnType,
            accessLevel: accessLevel,
            isStatic: isStatic,
            isAsync: isAsync,
            isThrowing: isThrowing,
            genericParameters: genericParameters
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
    
    // MARK: - Additional Parsing Methods
    
    private func parseMethodElement(from node: FunctionDeclSyntax) -> MethodElement {
        let name = node.name.text
        let accessLevel = parseAccessLevel(from: node.modifiers)
        let parameters = parseParameterClause(node.signature.parameterClause)
        let returnType = parseReturnClause(node.signature.returnClause)
        let isStatic = node.modifiers.contains { $0.name.text == "static" }
        let isAsync = node.signature.effectSpecifiers?.asyncSpecifier != nil
        let isThrowing = node.signature.effectSpecifiers?.throwsSpecifier != nil
        let isMutating = node.modifiers.contains { $0.name.text == "mutating" }
        let genericParameters: [String] = [] // TODO: Parse generic parameters properly
        
        return MethodElement(
            name: name,
            parameters: parameters,
            returnType: returnType,
            accessLevel: accessLevel,
            isStatic: isStatic,
            isAsync: isAsync,
            isThrowing: isThrowing,
            isMutating: isMutating,
            genericParameters: genericParameters
        )
    }
    
    private func parsePropertyElements(from node: VariableDeclSyntax) -> [PropertyElement] {
        let accessLevel = parseAccessLevel(from: node.modifiers)
        let isStatic = node.modifiers.contains { $0.name.text == "static" }
        let isLazy = node.modifiers.contains { $0.name.text == "lazy" }
        
        var properties: [PropertyElement] = []
        
        for binding in node.bindings {
            if let pattern = binding.pattern.as(IdentifierPatternSyntax.self) {
                let name = pattern.identifier.text
                let type = extractTypeFromBinding(binding)
                let hasGetter = true // In protocols, properties always have at least a getter
                let hasSetter = binding.accessorBlock?.accessors.as(AccessorDeclListSyntax.self)?.contains { 
                    $0.accessorSpecifier.text == "set" 
                } ?? !isComputedProperty(binding)
                
                let property = PropertyElement(
                    name: name,
                    type: type,
                    accessLevel: accessLevel,
                    isStatic: isStatic,
                    hasGetter: hasGetter,
                    hasSetter: hasSetter,
                    isLazy: isLazy
                )
                properties.append(property)
            }
        }
        
        return properties
    }
    
    private func parseInitializerElement(from node: InitializerDeclSyntax) -> InitializerElement {
        let accessLevel = parseAccessLevel(from: node.modifiers)
        let parameters = parseParameterClause(node.signature.parameterClause)
        let isFailable = node.optionalMark != nil
        let isConvenience = node.modifiers.contains { $0.name.text == "convenience" }
        let isThrowing = node.signature.effectSpecifiers?.throwsSpecifier != nil
        
        return InitializerElement(
            parameters: parameters,
            accessLevel: accessLevel,
            isFailable: isFailable,
            isConvenience: isConvenience,
            isThrowing: isThrowing
        )
    }
    
    private func parseAssociatedTypeElement(from node: AssociatedTypeDeclSyntax) -> AssociatedTypeElement {
        let name = node.name.text
        let constraint = node.inheritanceClause?.inheritedTypes.first?.type.description.trimmingCharacters(in: .whitespaces)
        let defaultType = node.initializer?.value.description.trimmingCharacters(in: .whitespaces)
        
        return AssociatedTypeElement(
            name: name,
            constraint: constraint,
            defaultType: defaultType
        )
    }
    
    private func parseGenericParameterClause(_ clause: GenericParameterClauseSyntax?) -> [String] {
        guard let clause = clause else { return [] }
        
        return clause.parameters.map { parameter in
            parameter.name.text
        }
    }
    
    private func extractTypeFromBinding(_ binding: PatternBindingSyntax) -> String {
        if let typeAnnotation = binding.typeAnnotation {
            return typeAnnotation.type.description.trimmingCharacters(in: .whitespaces)
        } else if let initializer = binding.initializer {
            // Try to infer type from initializer (simplified approach)
            return inferTypeFromInitializer(initializer.value)
        }
        return "Any" // Fallback
    }
    
    private func isComputedProperty(_ binding: PatternBindingSyntax) -> Bool {
        guard let accessorBlock = binding.accessorBlock else { return false }
        return accessorBlock.accessors.as(AccessorDeclListSyntax.self) != nil
    }
    
    private func inferTypeFromInitializer(_ expr: ExprSyntax) -> String {
        // Simplified type inference - in a real implementation, this would be more sophisticated
        let exprString = expr.description.trimmingCharacters(in: .whitespaces)
        
        if exprString.hasPrefix("\"") && exprString.hasSuffix("\"") {
            return "String"
        } else if exprString == "true" || exprString == "false" {
            return "Bool"
        } else if Int(exprString) != nil {
            return "Int"
        } else if Double(exprString) != nil {
            return "Double"
        } else if exprString.hasPrefix("[") && exprString.hasSuffix("]") {
            return "Array<Any>" // Simplified
        } else if exprString.hasPrefix("[") && exprString.contains(":") && exprString.hasSuffix("]") {
            return "Dictionary<String, Any>" // Simplified
        }
        
        return "Any"
    }
    
    private func isStandaloneFunction(_ node: FunctionDeclSyntax) -> Bool {
        // Check if the function is inside a protocol, class, or struct
        // by walking up the parent nodes
        var currentNode: SyntaxProtocol? = node.parent
        
        while let parent = currentNode {
            if parent.is(ProtocolDeclSyntax.self) ||
               parent.is(ClassDeclSyntax.self) ||
               parent.is(StructDeclSyntax.self) ||
               parent.is(ExtensionDeclSyntax.self) {
                return false
            }
            currentNode = parent.parent
        }
        
        return true
    }
}
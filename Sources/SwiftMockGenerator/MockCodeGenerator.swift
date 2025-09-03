import SwiftSyntax
import Foundation

/// Protocol that all mock generators must implement
protocol MockCodeGenerator {
    func generateMock(for declaration: any DeclSyntaxProtocol, in sourceFile: SourceFileSyntax, originalPath: String) throws -> String
}

/// Base class for mock generators with common functionality
class BaseMockGenerator: MockCodeGenerator {
    
    func generateMock(for declaration: any DeclSyntaxProtocol, in sourceFile: SourceFileSyntax, originalPath: String) throws -> String {
        fatalError("Subclasses must implement generateMock")
    }
    
    /// Extract imports from the original source file
    func extractImports(from sourceFile: SourceFileSyntax) -> [String] {
        var imports: [String] = []
        
        for statement in sourceFile.statements {
            if let importDecl = statement.item.as(ImportDeclSyntax.self) {
                let importText = importDecl.description.trimmingCharacters(in: .whitespacesAndNewlines)
                imports.append(importText)
            }
        }
        
        return imports
    }
    
    /// Extract function signatures from a declaration
    func extractFunctions(from declaration: any DeclSyntaxProtocol) -> [FunctionSignature] {
        var functions: [FunctionSignature] = []
        
        if let classDecl = declaration.as(ClassDeclSyntax.self) {
            functions = extractFunctionsFromMembers(classDecl.memberBlock.members)
        } else if let protocolDecl = declaration.as(ProtocolDeclSyntax.self) {
            functions = extractFunctionsFromMembers(protocolDecl.memberBlock.members)
        } else if let functionDecl = declaration.as(FunctionDeclSyntax.self) {
            if let signature = createFunctionSignature(from: functionDecl) {
                functions = [signature]
            }
        }
        
        return functions
    }
    
    /// Extract functions from member block
    private func extractFunctionsFromMembers(_ members: MemberBlockItemListSyntax) -> [FunctionSignature] {
        var functions: [FunctionSignature] = []
        
        for member in members {
            if let functionDecl = member.decl.as(FunctionDeclSyntax.self) {
                if let signature = createFunctionSignature(from: functionDecl) {
                    functions.append(signature)
                }
            }
        }
        
        return functions
    }
    
    /// Create function signature from FunctionDeclSyntax
    func createFunctionSignature(from functionDecl: FunctionDeclSyntax) -> FunctionSignature? {
        let name = functionDecl.name.text
        
        // Extract parameters
        let parameters = functionDecl.signature.parameterClause.parameters.map { param in
            FunctionSignature.Parameter(
                firstName: param.firstName?.text,
                secondName: param.secondName?.text ?? param.firstName.text,
                type: param.type.description.trimmingCharacters(in: .whitespaces),
                hasDefaultValue: param.defaultValue != nil
            )
        }
        
        // Extract return type
        let returnType = functionDecl.signature.returnClause?.type.description.trimmingCharacters(in: .whitespaces)
        
        // Check modifiers
        let isAsync = functionDecl.signature.effectSpecifiers?.asyncSpecifier != nil
        let isThrowing = functionDecl.signature.effectSpecifiers?.throwsSpecifier != nil
        let isStatic = functionDecl.modifiers.contains { $0.name.text == "static" }
        
        // Extract access level
        let accessLevel = extractAccessLevel(from: functionDecl.modifiers)
        
        return FunctionSignature(
            name: name,
            parameters: parameters,
            returnType: returnType,
            isAsync: isAsync,
            isThrowing: isThrowing,
            isStatic: isStatic,
            accessLevel: accessLevel
        )
    }
    
    /// Extract access level from modifiers
    private func extractAccessLevel(from modifiers: DeclModifierListSyntax) -> String {
        for modifier in modifiers {
            switch modifier.name.text {
            case "public", "internal", "private", "fileprivate":
                return modifier.name.text
            default:
                continue
            }
        }
        return "internal" // Default access level
    }
    
    /// Generate default return value for a given type
    func generateDefaultReturnValue(for type: String) -> String {
        let cleanType = type.trimmingCharacters(in: .whitespaces)
        
        switch cleanType {
        case "Void", "()":
            return ""
        case "String":
            return "return \"\""
        case "Int":
            return "return 0"
        case "Double", "Float":
            return "return 0.0"
        case "Bool":
            return "return false"
        case let t where t.hasPrefix("[") && t.hasSuffix("]"):
            return "return []"
        case let t where t.hasPrefix("Set<") && t.hasSuffix(">"):
            return "return Set()"
        case let t where t.hasPrefix("Dictionary<") && t.hasSuffix(">"):
            return "return [:]"
        case let t where t.hasSuffix("?"):
            return "return nil"
        default:
            if cleanType.contains("->") {
                // Function type - return a closure that does nothing
                return "return { _ in }"
            } else {
                // For custom types, try to initialize with empty initializer
                return "return \(cleanType)()"
            }
        }
    }
}
import SwiftSyntax
import Foundation

/// Generates dummy implementations with minimal, do-nothing behavior
class DummyGenerator: BaseMockGenerator {
    
    override func generateMock(for declaration: any DeclSyntaxProtocol, in sourceFile: SourceFileSyntax, originalPath: String) throws -> String {
        let imports = extractImports(from: sourceFile)
        let declarationName = extractDeclarationName(from: declaration)
        
        var mockCode = generateHeader(originalPath: originalPath, declarationName: declarationName)
        mockCode += generateImports(imports)
        mockCode += "\n"
        
        if let classDecl = declaration.as(ClassDeclSyntax.self) {
            mockCode += generateClassDummy(from: classDecl)
        } else if let protocolDecl = declaration.as(ProtocolDeclSyntax.self) {
            mockCode += generateProtocolDummy(from: protocolDecl)
        } else if let enumDecl = declaration.as(EnumDeclSyntax.self) {
            mockCode += generateEnumDummy(from: enumDecl)
        } else if let functionDecl = declaration.as(FunctionDeclSyntax.self) {
            mockCode += generateFunctionDummy(from: functionDecl)
        } else {
            throw MockGeneratorError.unsupportedDeclaration(String(describing: type(of: declaration)))
        }
        
        return mockCode
    }
    
    private func generateHeader(originalPath: String, declarationName: String) -> String {
        let fileName = URL(fileURLWithPath: originalPath).lastPathComponent
        return """
        //
        // \(declarationName)Dummy.swift
        // Generated dummy mock from \(fileName)
        // Created by SwiftMockGenerator
        //
        
        """
    }
    
    private func generateImports(_ imports: [String]) -> String {
        var result = ""
        for importStatement in imports {
            result += "\(importStatement)\n"
        }
        if !imports.contains("Foundation") && !imports.contains(where: { $0.contains("Foundation") }) {
            result += "import Foundation\n"
        }
        return result
    }
    
    private func generateClassDummy(from classDecl: ClassDeclSyntax) -> String {
        let className = classDecl.name.text
        let dummyClassName = "\(className)Dummy"
        let functions = extractFunctions(from: classDecl)
        
        var classCode = "class \(dummyClassName): \(className) {\n"
        
        // Generate minimal initializer
        classCode += "    override init() {\n"
        classCode += "        super.init()\n"
        classCode += "    }\n\n"
        
        // Generate dummy methods (only for non-inherited methods)
        for function in functions {
            classCode += generateDummyMethod(from: function)
            classCode += "\n"
        }
        
        classCode += "}\n"
        return classCode
    }
    
    private func generateProtocolDummy(from protocolDecl: ProtocolDeclSyntax) -> String {
        let protocolName = protocolDecl.name.text
        let dummyClassName = "\(protocolName)Dummy"
        let functions = extractFunctions(from: protocolDecl)
        
        var classCode = "class \(dummyClassName): \(protocolName) {\n"
        
        // Generate minimal initializer
        classCode += "    init() {}\n\n"
        
        // Generate dummy methods
        for function in functions {
            classCode += generateDummyMethod(from: function)
            classCode += "\n"
        }
        
        classCode += "}\n"
        return classCode
    }
    
    private func generateEnumDummy(from enumDecl: EnumDeclSyntax) -> String {
        let enumName = enumDecl.name.text
        let dummyClassName = "\(enumName)Dummy"
        
        // For enums, we create a helper class that provides a dummy value
        var classCode = "class \(dummyClassName) {\n"
        classCode += "    static let value: \(enumName) = .\(extractFirstCase(from: enumDecl))\n"
        classCode += "    \n"
        classCode += "    private init() {} // Prevent instantiation\n"
        classCode += "}\n"
        
        return classCode
    }
    
    private func generateFunctionDummy(from functionDecl: FunctionDeclSyntax) -> String {
        let signature = createFunctionSignature(from: functionDecl)!
        let functionName = "\(signature.name)Dummy"
        
        var functionCode = "func \(functionName)"
        functionCode += generateParameterList(from: signature)
        
        if let returnType = signature.returnType {
            functionCode += " -> \(returnType)"
        }
        
        if signature.isAsync {
            functionCode += " async"
        }
        
        if signature.isThrowing {
            functionCode += " throws"
        }
        
        functionCode += " {\n"
        functionCode += "    // Dummy implementation - does nothing\n"
        
        if let returnType = signature.returnType, returnType != "Void" {
            let defaultReturn = generateMinimalReturnValue(for: returnType)
            functionCode += "    \(defaultReturn)\n"
        }
        
        functionCode += "}\n"
        
        return functionCode
    }
    
    private func generateDummyMethod(from signature: FunctionSignature) -> String {
        var methodCode = "    \(signature.accessLevel) func \(signature.name)"
        methodCode += generateParameterList(from: signature)
        
        if let returnType = signature.returnType {
            methodCode += " -> \(returnType)"
        }
        
        if signature.isAsync {
            methodCode += " async"
        }
        
        if signature.isThrowing {
            methodCode += " throws"
        }
        
        methodCode += " {\n"
        methodCode += "        // Dummy implementation - does nothing\n"
        
        if let returnType = signature.returnType, returnType != "Void" {
            let defaultReturn = generateMinimalReturnValue(for: returnType)
            methodCode += "        \(defaultReturn)\n"
        }
        
        methodCode += "    }"
        
        return methodCode
    }
    
    private func generateParameterList(from signature: FunctionSignature) -> String {
        guard !signature.parameters.isEmpty else { return "()" }
        
        let params = signature.parameters.map { param in
            var paramStr = ""
            if let firstName = param.firstName {
                paramStr = "\(firstName) \(param.secondName): \(param.type)"
            } else {
                paramStr = "\(param.secondName): \(param.type)"
            }
            return paramStr
        }.joined(separator: ", ")
        
        return "(\(params))"
    }
    
    /// Generate minimal return values for dummy implementations
    private func generateMinimalReturnValue(for type: String) -> String {
        let cleanType = type.trimmingCharacters(in: .whitespaces)
        
        switch cleanType {
        case "Void", "()":
            return ""
        case "String":
            return "return \"\"" // Empty string
        case "Int", "Int8", "Int16", "Int32", "Int64":
            return "return 0"
        case "UInt", "UInt8", "UInt16", "UInt32", "UInt64":
            return "return 0"
        case "Double", "Float", "CGFloat":
            return "return 0.0"
        case "Bool":
            return "return false"
        case let t where t.hasPrefix("[") && t.hasSuffix("]"):
            return "return []" // Empty array
        case let t where t.hasPrefix("Set<") && t.hasSuffix(">"):
            return "return Set()" // Empty set
        case let t where t.hasPrefix("Dictionary<") && t.hasSuffix(">"):
            return "return [:]" // Empty dictionary
        case let t where t.hasSuffix("?"):
            return "return nil" // Optional types return nil
        default:
            if cleanType.contains("->") {
                // Function type - return empty closure
                return "return { _ in }"
            } else if cleanType.starts(with: "@") {
                // Escaping closures
                return "return { _ in }"
            } else {
                // For custom types, return fatalError to make it obvious this is a dummy
                return "fatalError(\"Dummy implementation - not meant to be called\")"
            }
        }
    }
    
    private func extractDeclarationName(from declaration: any DeclSyntaxProtocol) -> String {
        if let classDecl = declaration.as(ClassDeclSyntax.self) {
            return classDecl.name.text
        } else if let protocolDecl = declaration.as(ProtocolDeclSyntax.self) {
            return protocolDecl.name.text
        } else if let enumDecl = declaration.as(EnumDeclSyntax.self) {
            return enumDecl.name.text
        } else if let functionDecl = declaration.as(FunctionDeclSyntax.self) {
            return functionDecl.name.text
        }
        return "Unknown"
    }
    
    private func extractFirstCase(from enumDecl: EnumDeclSyntax) -> String {
        for member in enumDecl.memberBlock.members {
            if let caseDecl = member.decl.as(EnumCaseDeclSyntax.self) {
                if let firstCase = caseDecl.elements.first {
                    return firstCase.name.text
                }
            }
        }
        return "defaultCase"
    }
}
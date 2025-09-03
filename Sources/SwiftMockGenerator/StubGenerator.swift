import SwiftSyntax
import Foundation

/// Generates stub implementations that return default values
class StubGenerator: BaseMockGenerator {
    
    override func generateMock(for declaration: any DeclSyntaxProtocol, in sourceFile: SourceFileSyntax, originalPath: String) throws -> String {
        let imports = extractImports(from: sourceFile)
        let declarationName = extractDeclarationName(from: declaration)
        
        var mockCode = generateHeader(originalPath: originalPath, declarationName: declarationName)
        mockCode += generateImports(imports)
        mockCode += "\n"
        
        if let classDecl = declaration.as(ClassDeclSyntax.self) {
            mockCode += generateClassStub(from: classDecl)
        } else if let protocolDecl = declaration.as(ProtocolDeclSyntax.self) {
            mockCode += generateProtocolStub(from: protocolDecl)
        } else if let enumDecl = declaration.as(EnumDeclSyntax.self) {
            mockCode += generateEnumStub(from: enumDecl)
        } else if let functionDecl = declaration.as(FunctionDeclSyntax.self) {
            mockCode += generateFunctionStub(from: functionDecl)
        } else {
            throw MockGeneratorError.unsupportedDeclaration(String(describing: type(of: declaration)))
        }
        
        return mockCode
    }
    
    private func generateHeader(originalPath: String, declarationName: String) -> String {
        let fileName = URL(fileURLWithPath: originalPath).lastPathComponent
        return """
        //
        // \(declarationName)Stub.swift
        // Generated stub mock from \(fileName)
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
    
    private func generateClassStub(from classDecl: ClassDeclSyntax) -> String {
        let className = classDecl.name.text
        let stubClassName = "\(className)Stub"
        let functions = extractFunctions(from: classDecl)
        
        var classCode = "class \(stubClassName): \(className) {\n"
        
        // Generate initializer if needed
        classCode += "    override init() {\n"
        classCode += "        super.init()\n"
        classCode += "    }\n\n"
        
        // Generate stub methods
        for function in functions {
            classCode += generateStubMethod(from: function)
            classCode += "\n"
        }
        
        classCode += "}\n"
        return classCode
    }
    
    private func generateProtocolStub(from protocolDecl: ProtocolDeclSyntax) -> String {
        let protocolName = protocolDecl.name.text
        let stubClassName = "\(protocolName)Stub"
        let functions = extractFunctions(from: protocolDecl)
        
        var classCode = "class \(stubClassName): \(protocolName) {\n"
        
        // Generate initializer
        classCode += "    init() {}\n\n"
        
        // Generate stub methods
        for function in functions {
            classCode += generateStubMethod(from: function)
            classCode += "\n"
        }
        
        classCode += "}\n"
        return classCode
    }
    
    private func generateEnumStub(from enumDecl: EnumDeclSyntax) -> String {
        let enumName = enumDecl.name.text
        let stubClassName = "\(enumName)Stub"
        
        // For enums, we create a helper class that can provide stub values
        var classCode = "class \(stubClassName) {\n"
        classCode += "    static let defaultValue: \(enumName) = .\(extractFirstCase(from: enumDecl))\n"
        classCode += "    \n"
        classCode += "    static func randomValue() -> \(enumName) {\n"
        classCode += "        let allCases: [\(enumName)] = [\(generateAllCases(from: enumDecl))]\n"
        classCode += "        return allCases.randomElement() ?? defaultValue\n"
        classCode += "    }\n"
        classCode += "}\n"
        
        return classCode
    }
    
    private func generateFunctionStub(from functionDecl: FunctionDeclSyntax) -> String {
        let signature = createFunctionSignature(from: functionDecl)!
        let functionName = "\(signature.name)Stub"
        
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
        
        if let returnType = signature.returnType, returnType != "Void" {
            let defaultReturn = generateDefaultReturnValue(for: returnType)
            functionCode += "    \(defaultReturn)\n"
        }
        
        functionCode += "}\n"
        
        return functionCode
    }
    
    private func generateStubMethod(from signature: FunctionSignature) -> String {
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
        
        if let returnType = signature.returnType, returnType != "Void" {
            let defaultReturn = generateDefaultReturnValue(for: returnType)
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
    
    private func generateAllCases(from enumDecl: EnumDeclSyntax) -> String {
        var cases: [String] = []
        
        for member in enumDecl.memberBlock.members {
            if let caseDecl = member.decl.as(EnumCaseDeclSyntax.self) {
                for element in caseDecl.elements {
                    cases.append(".\(element.name.text)")
                }
            }
        }
        
        return cases.joined(separator: ", ")
    }
}
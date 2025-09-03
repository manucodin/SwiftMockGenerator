import SwiftSyntax
import Foundation

/// Generates spy implementations that track method calls and parameters
class SpyGenerator: BaseMockGenerator {
    
    override func generateMock(for declaration: any DeclSyntaxProtocol, in sourceFile: SourceFileSyntax, originalPath: String) throws -> String {
        let imports = extractImports(from: sourceFile)
        let declarationName = extractDeclarationName(from: declaration)
        
        var mockCode = generateHeader(originalPath: originalPath, declarationName: declarationName)
        mockCode += generateImports(imports)
        mockCode += "\n"
        
        if let classDecl = declaration.as(ClassDeclSyntax.self) {
            mockCode += generateClassSpy(from: classDecl)
        } else if let protocolDecl = declaration.as(ProtocolDeclSyntax.self) {
            mockCode += generateProtocolSpy(from: protocolDecl)
        } else if let functionDecl = declaration.as(FunctionDeclSyntax.self) {
            mockCode += generateFunctionSpy(from: functionDecl)
        } else {
            throw MockGeneratorError.unsupportedDeclaration(String(describing: type(of: declaration)))
        }
        
        return mockCode
    }
    
    private func generateHeader(originalPath: String, declarationName: String) -> String {
        let fileName = URL(fileURLWithPath: originalPath).lastPathComponent
        return """
        //
        // \(declarationName)Spy.swift
        // Generated spy mock from \(fileName)
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
    
    private func generateClassSpy(from classDecl: ClassDeclSyntax) -> String {
        let className = classDecl.name.text
        let spyClassName = "\(className)Spy"
        let functions = extractFunctions(from: classDecl)
        
        var classCode = "class \(spyClassName): \(className) {\n"
        
        // Generate call tracking properties
        classCode += generateCallTrackingProperties(for: functions)
        classCode += "\n"
        
        // Generate initializer
        classCode += "    override init() {\n"
        classCode += "        super.init()\n"
        classCode += "    }\n\n"
        
        // Generate spy methods
        for function in functions {
            classCode += generateSpyMethod(from: function)
            classCode += "\n"
        }
        
        // Generate verification methods
        classCode += generateVerificationMethods(for: functions)
        
        classCode += "}\n"
        return classCode
    }
    
    private func generateProtocolSpy(from protocolDecl: ProtocolDeclSyntax) -> String {
        let protocolName = protocolDecl.name.text
        let spyClassName = "\(protocolName)Spy"
        let functions = extractFunctions(from: protocolDecl)
        
        var classCode = "class \(spyClassName): \(protocolName) {\n"
        
        // Generate call tracking properties
        classCode += generateCallTrackingProperties(for: functions)
        classCode += "\n"
        
        // Generate initializer
        classCode += "    init() {}\n\n"
        
        // Generate spy methods
        for function in functions {
            classCode += generateSpyMethod(from: function)
            classCode += "\n"
        }
        
        // Generate verification methods
        classCode += generateVerificationMethods(for: functions)
        
        classCode += "}\n"
        return classCode
    }
    
    private func generateFunctionSpy(from functionDecl: FunctionDeclSyntax) -> String {
        let signature = createFunctionSignature(from: functionDecl)!
        let spyClassName = "\(signature.name)Spy"
        
        var classCode = "class \(spyClassName) {\n"
        
        // Generate call tracking properties
        classCode += generateCallTrackingProperties(for: [signature])
        classCode += "\n"
        
        // Generate initializer
        classCode += "    init() {}\n\n"
        
        // Generate the spy function
        classCode += generateSpyFunction(from: signature)
        classCode += "\n"
        
        // Generate verification methods
        classCode += generateVerificationMethods(for: [signature])
        
        classCode += "}\n"
        return classCode
    }
    
    private func generateCallTrackingProperties(for functions: [FunctionSignature]) -> String {
        var properties = ""
        
        for function in functions {
            let functionName = function.name
            properties += "    private(set) var \(functionName)CallCount = 0\n"
            properties += "    private(set) var \(functionName)Called = false\n"
            
            if !function.parameters.isEmpty {
                properties += "    private(set) var \(functionName)ReceivedParameters: [(\(generateParameterTuple(from: function)))] = []\n"
            }
        }
        
        return properties
    }
    
    private func generateSpyMethod(from signature: FunctionSignature) -> String {
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
        methodCode += "        \(signature.name)CallCount += 1\n"
        methodCode += "        \(signature.name)Called = true\n"
        
        if !signature.parameters.isEmpty {
            let parameterNames = signature.parameters.map { $0.secondName }.joined(separator: ", ")
            methodCode += "        \(signature.name)ReceivedParameters.append((\(parameterNames)))\n"
        }
        
        if let returnType = signature.returnType, returnType != "Void" {
            let defaultReturn = generateDefaultReturnValue(for: returnType)
            methodCode += "        \(defaultReturn)\n"
        }
        
        methodCode += "    }"
        
        return methodCode
    }
    
    private func generateSpyFunction(from signature: FunctionSignature) -> String {
        var functionCode = "    func \(signature.name)"
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
        functionCode += "        \(signature.name)CallCount += 1\n"
        functionCode += "        \(signature.name)Called = true\n"
        
        if !signature.parameters.isEmpty {
            let parameterNames = signature.parameters.map { $0.secondName }.joined(separator: ", ")
            functionCode += "        \(signature.name)ReceivedParameters.append((\(parameterNames)))\n"
        }
        
        if let returnType = signature.returnType, returnType != "Void" {
            let defaultReturn = generateDefaultReturnValue(for: returnType)
            functionCode += "        \(defaultReturn)\n"
        }
        
        functionCode += "    }"
        
        return functionCode
    }
    
    private func generateVerificationMethods(for functions: [FunctionSignature]) -> String {
        var verificationMethods = "\n    // MARK: - Verification Methods\n"
        
        for function in functions {
            let functionName = function.name
            
            // Method to verify if function was called
            verificationMethods += """
                
                func verify\(functionName.capitalized)Called() -> Bool {
                    return \(functionName)Called
                }
                
                func verify\(functionName.capitalized)CallCount(_ expectedCount: Int) -> Bool {
                    return \(functionName)CallCount == expectedCount
                }
                
            """
            
            // Method to verify parameters if function has any
            if !function.parameters.isEmpty {
                verificationMethods += """
                func verify\(functionName.capitalized)CalledWith(\(generateParameterList(from: function, includeTypes: true))) -> Bool {
                    return \(functionName)ReceivedParameters.contains { receivedParams in
                        \(generateParameterComparison(from: function))
                    }
                }
                
                """
            }
        }
        
        return verificationMethods
    }
    
    private func generateParameterList(from signature: FunctionSignature, includeTypes: Bool = true) -> String {
        guard !signature.parameters.isEmpty else { return "()" }
        
        let params = signature.parameters.map { param in
            var paramStr = ""
            if let firstName = param.firstName {
                paramStr = "\(firstName) \(param.secondName)"
            } else {
                paramStr = "\(param.secondName)"
            }
            
            if includeTypes {
                paramStr += ": \(param.type)"
            }
            
            return paramStr
        }.joined(separator: ", ")
        
        return "(\(params))"
    }
    
    private func generateParameterTuple(from signature: FunctionSignature) -> String {
        let types = signature.parameters.map { $0.type }.joined(separator: ", ")
        return types
    }
    
    private func generateParameterComparison(from signature: FunctionSignature) -> String {
        let comparisons = signature.parameters.enumerated().map { index, param in
            return "receivedParams.\(index) == \(param.secondName)"
        }.joined(separator: " && ")
        
        return comparisons
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
}
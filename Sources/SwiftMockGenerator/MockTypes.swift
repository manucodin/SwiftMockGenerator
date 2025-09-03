import SwiftSyntax

/// Types of mocks that can be generated
enum MockType: String, CaseIterable {
    case stub = "Stub"
    case spy = "Spy"
    case dummy = "Dummy"
    
    var commentPattern: String {
        return "@\(rawValue)"
    }
}

/// Represents a mock annotation found in the source code
struct MockAnnotation {
    let mockType: MockType
    let declaration: any DeclSyntaxProtocol
    let declarationName: String
    let lineNumber: Int
    
    init(mockType: MockType, declaration: any DeclSyntaxProtocol, declarationName: String, lineNumber: Int) {
        self.mockType = mockType
        self.declaration = declaration
        self.declarationName = declarationName
        self.lineNumber = lineNumber
    }
}

/// Supported Swift declaration types for mock generation
enum SupportedDeclarationType {
    case `class`(ClassDeclSyntax)
    case `protocol`(ProtocolDeclSyntax)
    case `enum`(EnumDeclSyntax)
    case function(FunctionDeclSyntax)
    
    var name: String {
        switch self {
        case .class(let decl):
            return decl.name.text
        case .protocol(let decl):
            return decl.name.text
        case .enum(let decl):
            return decl.name.text
        case .function(let decl):
            return decl.name.text
        }
    }
}

/// Function signature information for mock generation
struct FunctionSignature {
    let name: String
    let parameters: [Parameter]
    let returnType: String?
    let isAsync: Bool
    let isThrowing: Bool
    let isStatic: Bool
    let accessLevel: String
    
    struct Parameter {
        let firstName: String?  // external parameter name
        let secondName: String  // internal parameter name
        let type: String
        let hasDefaultValue: Bool
        
        var fullName: String {
            if let firstName = firstName {
                return "\(firstName) \(secondName)"
            }
            return secondName
        }
    }
}
import Foundation
import SwiftSyntax

// MARK: - Mock Annotation Types

/// Types of mock annotations supported
public enum MockType: String, CaseIterable {
    case stub = "Stub"
    case spy = "Spy"
    case dummy = "Dummy"
}

/// Represents a mock annotation found in source code
public struct MockAnnotation {
    let type: MockType
    let element: CodeElement
    let location: SourceLocation
    
    public init(type: MockType, element: CodeElement, location: SourceLocation) {
        self.type = type
        self.element = element
        self.location = location
    }
}

/// Source location information
public struct SourceLocation {
    let line: Int
    let column: Int
    let file: String
    
    public init(line: Int, column: Int, file: String) {
        self.line = line
        self.column = column
        self.file = file
    }
}

// MARK: - Code Elements

/// Represents different types of Swift code elements that can be mocked
public enum CodeElement {
    case `protocol`(ProtocolElement)
    case `class`(ClassElement)
    case function(FunctionElement)
    
    var name: String {
        switch self {
        case .protocol(let element):
            return element.name
        case .class(let element):
            return element.name
        case .function(let element):
            return element.name
        }
    }
    
    var isReference: Bool {
        switch self {
        case .protocol, .class:
            return true
        case .function:
            return false
        }
    }
}

/// Protocol element information
public struct ProtocolElement {
    let name: String
    let methods: [MethodElement]
    let properties: [PropertyElement]
    let inheritance: [String]
    let accessLevel: AccessLevel
    let genericParameters: [String]
    
    public init(name: String, methods: [MethodElement] = [], properties: [PropertyElement] = [],
                inheritance: [String] = [], accessLevel: AccessLevel = .internal, genericParameters: [String] = []) {
        self.name = name
        self.methods = methods
        self.properties = properties
        self.inheritance = inheritance
        self.accessLevel = accessLevel
        self.genericParameters = genericParameters
    }
}

/// Class element information
public struct ClassElement {
    let name: String
    let methods: [MethodElement]
    let properties: [PropertyElement]
    let initializers: [InitializerElement]
    let inheritance: [String]
    let accessLevel: AccessLevel
    let genericParameters: [String]
    let isFinal: Bool
    
    public init(name: String, methods: [MethodElement] = [], properties: [PropertyElement] = [],
                initializers: [InitializerElement] = [], inheritance: [String] = [],
                accessLevel: AccessLevel = .internal, genericParameters: [String] = [], isFinal: Bool = false) {
        self.name = name
        self.methods = methods
        self.properties = properties
        self.initializers = initializers
        self.inheritance = inheritance
        self.accessLevel = accessLevel
        self.genericParameters = genericParameters
        self.isFinal = isFinal
    }
}


/// Function element information
public struct FunctionElement {
    let name: String
    let parameters: [ParameterElement]
    let returnType: String?
    let accessLevel: AccessLevel
    let isStatic: Bool
    let isAsync: Bool
    let isThrowing: Bool
    let genericParameters: [String]
    
    public init(name: String, parameters: [ParameterElement] = [], returnType: String? = nil,
                accessLevel: AccessLevel = .internal, isStatic: Bool = false, isAsync: Bool = false,
                isThrowing: Bool = false, genericParameters: [String] = []) {
        self.name = name
        self.parameters = parameters
        self.returnType = returnType
        self.accessLevel = accessLevel
        self.isStatic = isStatic
        self.isAsync = isAsync
        self.isThrowing = isThrowing
        self.genericParameters = genericParameters
    }
}

// MARK: - Supporting Elements

/// Method information
public struct MethodElement {
    let name: String
    let parameters: [ParameterElement]
    let returnType: String?
    let accessLevel: AccessLevel
    let isStatic: Bool
    let isAsync: Bool
    let isThrowing: Bool
    let isMutating: Bool
    let genericParameters: [String]
    
    public init(name: String, parameters: [ParameterElement] = [], returnType: String? = nil,
                accessLevel: AccessLevel = .internal, isStatic: Bool = false, isAsync: Bool = false,
                isThrowing: Bool = false, isMutating: Bool = false, genericParameters: [String] = []) {
        self.name = name
        self.parameters = parameters
        self.returnType = returnType
        self.accessLevel = accessLevel
        self.isStatic = isStatic
        self.isAsync = isAsync
        self.isThrowing = isThrowing
        self.isMutating = isMutating
        self.genericParameters = genericParameters
    }
}

/// Property information
public struct PropertyElement {
    let name: String
    let type: String
    let accessLevel: AccessLevel
    let isStatic: Bool
    let hasGetter: Bool
    let hasSetter: Bool
    let isLazy: Bool
    
    public init(name: String, type: String, accessLevel: AccessLevel = .internal, 
                isStatic: Bool = false, hasGetter: Bool = true, hasSetter: Bool = false, isLazy: Bool = false) {
        self.name = name
        self.type = type
        self.accessLevel = accessLevel
        self.isStatic = isStatic
        self.hasGetter = hasGetter
        self.hasSetter = hasSetter
        self.isLazy = isLazy
    }
}

/// Parameter information
public struct ParameterElement {
    let externalName: String?
    let internalName: String
    let type: String
    let defaultValue: String?
    let isInout: Bool
    let isVariadic: Bool
    
    public init(externalName: String? = nil, internalName: String, type: String, 
                defaultValue: String? = nil, isInout: Bool = false, isVariadic: Bool = false) {
        self.externalName = externalName
        self.internalName = internalName
        self.type = type
        self.defaultValue = defaultValue
        self.isInout = isInout
        self.isVariadic = isVariadic
    }
}

/// Initializer information
public struct InitializerElement {
    let parameters: [ParameterElement]
    let accessLevel: AccessLevel
    let isFailable: Bool
    let isConvenience: Bool
    let isThrowing: Bool
    
    public init(parameters: [ParameterElement] = [], accessLevel: AccessLevel = .internal,
                isFailable: Bool = false, isConvenience: Bool = false, isThrowing: Bool = false) {
        self.parameters = parameters
        self.accessLevel = accessLevel
        self.isFailable = isFailable
        self.isConvenience = isConvenience
        self.isThrowing = isThrowing
    }
}


/// Access level enumeration
public enum AccessLevel: String, CaseIterable {
    case `private` = "private"
    case `fileprivate` = "fileprivate"
    case `internal` = "internal"
    case `public` = "public"
    case `open` = "open"
    
    var keyword: String {
        switch self {
        case .internal:
            return ""
        default:
            return rawValue + " "
        }
    }
}

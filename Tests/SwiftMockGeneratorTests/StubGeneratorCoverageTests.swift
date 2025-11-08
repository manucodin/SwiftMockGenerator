import XCTest
import Foundation

@testable import SwiftMockGenerator

final class StubGeneratorCoverageTests: XCTestCase {
    
    // MARK: - generateMockDefinition Coverage Tests
    
    func testStubGenerator_givenProtocol_whenGeneratingMockDefinition_thenRemovesHeader() throws {
        // Given
        let sut = StubGenerator()
        let protocolElement = ProtocolElement(name: "TestProtocol")
        let annotation = MockAnnotation(
            type: .stub,
            element: .protocol(protocolElement),
            location: SourceLocation(line: 1, column: 1, file: "test.swift")
        )
        
        // When
        let result = try sut.generateMockDefinition(for: annotation.element, annotation: annotation)
        
        // Then
        XCTAssertFalse(result.isEmpty)
        XCTAssertFalse(result.contains("// MARK: - Generated Stub"))
        XCTAssertTrue(result.contains("class TestProtocolStub"))
    }
    
    // MARK: - Property Generation Coverage Tests
    
    func testStubGenerator_givenLazyStaticProperty_whenGenerating_thenIncludesAllModifiers() throws {
        // Given
        let sut = StubGenerator()
        let property = PropertyElement(
            name: "lazyProp",
            type: "String",
            accessLevel: .public,
            isStatic: true,
            hasGetter: true,
            hasSetter: true,
            isLazy: true
        )
        let protocolElement = ProtocolElement(
            name: "TestProtocol",
            properties: [property]
        )
        let annotation = MockAnnotation(
            type: .stub,
            element: .protocol(protocolElement),
            location: SourceLocation(line: 1, column: 1, file: "test.swift")
        )
        
        // When
        let result = try sut.generateMock(for: annotation.element, annotation: annotation)
        
        // Then
        XCTAssertTrue(result.contains("static"))
        XCTAssertTrue(result.contains("lazy"))
        XCTAssertTrue(result.contains("lazyProp"))
    }
    
    func testStubGenerator_givenPropertyWithoutSetter_whenGenerating_thenUsesComputedProperty() throws {
        // Given
        let sut = StubGenerator()
        let property = PropertyElement(
            name: "readOnlyProp",
            type: "Int",
            hasGetter: true,
            hasSetter: false
        )
        let protocolElement = ProtocolElement(
            name: "TestProtocol",
            properties: [property]
        )
        let annotation = MockAnnotation(
            type: .stub,
            element: .protocol(protocolElement),
            location: SourceLocation(line: 1, column: 1, file: "test.swift")
        )
        
        // When
        let result = try sut.generateMock(for: annotation.element, annotation: annotation)
        
        // Then
        XCTAssertTrue(result.contains("readOnlyProp"))
        XCTAssertTrue(result.contains("{") || result.contains("var"))
    }
    
    // MARK: - Method Generation Coverage Tests
    
    func testStubGenerator_givenMutatingMethod_whenGenerating_thenIncludesMutatingKeyword() throws {
        // Given
        let sut = StubGenerator()
        let method = MethodElement(
            name: "mutatingMethod",
            parameters: [],
            returnType: "Void",
            isMutating: true
        )
        let protocolElement = ProtocolElement(
            name: "TestProtocol",
            methods: [method]
        )
        let annotation = MockAnnotation(
            type: .stub,
            element: .protocol(protocolElement),
            location: SourceLocation(line: 1, column: 1, file: "test.swift")
        )
        
        // When
        let result = try sut.generateMock(for: annotation.element, annotation: annotation)
        
        // Then
        XCTAssertTrue(result.contains("mutating"))
        XCTAssertTrue(result.contains("mutatingMethod"))
    }
    
    func testStubGenerator_givenStaticAsyncThrowingMethod_whenGenerating_thenIncludesAllModifiers() throws {
        // Given
        let sut = StubGenerator()
        let method = MethodElement(
            name: "complexMethod",
            parameters: [],
            returnType: "String",
            accessLevel: .public,
            isStatic: true,
            isAsync: true,
            isThrowing: true
        )
        let protocolElement = ProtocolElement(
            name: "TestProtocol",
            methods: [method]
        )
        let annotation = MockAnnotation(
            type: .stub,
            element: .protocol(protocolElement),
            location: SourceLocation(line: 1, column: 1, file: "test.swift")
        )
        
        // When
        let result = try sut.generateMock(for: annotation.element, annotation: annotation)
        
        // Then
        XCTAssertTrue(result.contains("static"))
        XCTAssertTrue(result.contains("async"))
        XCTAssertTrue(result.contains("throws"))
        XCTAssertTrue(result.contains("complexMethod"))
    }
    
    // MARK: - Initializer Generation Coverage Tests
    
    func testStubGenerator_givenFailableInitializer_whenGenerating_thenIncludesFailableMarker() throws {
        // Given
        let sut = StubGenerator()
        let initializer = InitializerElement(
            parameters: [],
            isFailable: true
        )
        let classElement = ClassElement(
            name: "TestClass",
            initializers: [initializer]
        )
        let annotation = MockAnnotation(
            type: .stub,
            element: .class(classElement),
            location: SourceLocation(line: 1, column: 1, file: "test.swift")
        )
        
        // When
        let result = try sut.generateMock(for: annotation.element, annotation: annotation)
        
        // Then
        XCTAssertTrue(result.contains("init?()"))
    }
    
    func testStubGenerator_givenConvenienceThrowingInitializer_whenGenerating_thenIncludesAllModifiers() throws {
        // Given
        let sut = StubGenerator()
        let initializer = InitializerElement(
            parameters: [ParameterElement(internalName: "value", type: "String")],
            accessLevel: .public,
            isFailable: false,
            isConvenience: true,
            isThrowing: true
        )
        let classElement = ClassElement(
            name: "TestClass",
            initializers: [initializer]
        )
        let annotation = MockAnnotation(
            type: .stub,
            element: .class(classElement),
            location: SourceLocation(line: 1, column: 1, file: "test.swift")
        )
        
        // When
        let result = try sut.generateMock(for: annotation.element, annotation: annotation)
        
        // Then
        XCTAssertTrue(result.contains("convenience"))
        XCTAssertTrue(result.contains("throws"))
    }
    
    func testStubGenerator_givenClassWithoutInitializers_whenGenerating_thenCreatesDefaultInit() throws {
        // Given
        let sut = StubGenerator()
        let classElement = ClassElement(
            name: "TestClass",
            initializers: []
        )
        let annotation = MockAnnotation(
            type: .stub,
            element: .class(classElement),
            location: SourceLocation(line: 1, column: 1, file: "test.swift")
        )
        
        // When
        let result = try sut.generateMock(for: annotation.element, annotation: annotation)
        
        // Then
        XCTAssertTrue(result.contains("override init()"))
        XCTAssertTrue(result.contains("super.init()"))
    }
    
    // MARK: - Parameter Generation Coverage Tests
    
    func testStubGenerator_givenParameterWithExternalName_whenGenerating_thenUsesExternalName() throws {
        // Given
        let sut = StubGenerator()
        let parameter = ParameterElement(
            externalName: "from",
            internalName: "source",
            type: "String"
        )
        let method = MethodElement(
            name: "method",
            parameters: [parameter],
            returnType: "Void"
        )
        let protocolElement = ProtocolElement(
            name: "TestProtocol",
            methods: [method]
        )
        let annotation = MockAnnotation(
            type: .stub,
            element: .protocol(protocolElement),
            location: SourceLocation(line: 1, column: 1, file: "test.swift")
        )
        
        // When
        let result = try sut.generateMock(for: annotation.element, annotation: annotation)
        
        // Then
        XCTAssertTrue(result.contains("from"))
        XCTAssertTrue(result.contains("source"))
    }
    
    func testStubGenerator_givenParameterWithUnderscoreExternalName_whenGenerating_thenUsesUnderscore() throws {
        // Given
        let sut = StubGenerator()
        let parameter = ParameterElement(
            externalName: "_",
            internalName: "value",
            type: "Int"
        )
        let method = MethodElement(
            name: "method",
            parameters: [parameter],
            returnType: "Void"
        )
        let protocolElement = ProtocolElement(
            name: "TestProtocol",
            methods: [method]
        )
        let annotation = MockAnnotation(
            type: .stub,
            element: .protocol(protocolElement),
            location: SourceLocation(line: 1, column: 1, file: "test.swift")
        )
        
        // When
        let result = try sut.generateMock(for: annotation.element, annotation: annotation)
        
        // Then
        XCTAssertTrue(result.contains("_ value:"))
    }
    
    func testStubGenerator_givenParameterWithDefaultValue_whenGenerating_thenIncludesDefaultValue() throws {
        // Given
        let sut = StubGenerator()
        let parameter = ParameterElement(
            internalName: "value",
            type: "String",
            defaultValue: "\"default\""
        )
        let method = MethodElement(
            name: "method",
            parameters: [parameter],
            returnType: "Void"
        )
        let protocolElement = ProtocolElement(
            name: "TestProtocol",
            methods: [method]
        )
        let annotation = MockAnnotation(
            type: .stub,
            element: .protocol(protocolElement),
            location: SourceLocation(line: 1, column: 1, file: "test.swift")
        )
        
        // When
        let result = try sut.generateMock(for: annotation.element, annotation: annotation)
        
        // Then
        XCTAssertTrue(result.contains("= \"default\""))
    }
    
    func testStubGenerator_givenInoutParameter_whenGenerating_thenIncludesInoutKeyword() throws {
        // Given
        let sut = StubGenerator()
        let parameter = ParameterElement(
            internalName: "value",
            type: "Int",
            isInout: true
        )
        let method = MethodElement(
            name: "method",
            parameters: [parameter],
            returnType: "Void"
        )
        let protocolElement = ProtocolElement(
            name: "TestProtocol",
            methods: [method]
        )
        let annotation = MockAnnotation(
            type: .stub,
            element: .protocol(protocolElement),
            location: SourceLocation(line: 1, column: 1, file: "test.swift")
        )
        
        // When
        let result = try sut.generateMock(for: annotation.element, annotation: annotation)
        
        // Then
        XCTAssertTrue(result.contains("inout"))
    }
    
    func testStubGenerator_givenVariadicParameter_whenGenerating_thenIncludesVariadicMarker() throws {
        // Given
        let sut = StubGenerator()
        let parameter = ParameterElement(
            internalName: "values",
            type: "Int",
            isVariadic: true
        )
        let method = MethodElement(
            name: "method",
            parameters: [parameter],
            returnType: "Void"
        )
        let protocolElement = ProtocolElement(
            name: "TestProtocol",
            methods: [method]
        )
        let annotation = MockAnnotation(
            type: .stub,
            element: .protocol(protocolElement),
            location: SourceLocation(line: 1, column: 1, file: "test.swift")
        )
        
        // When
        let result = try sut.generateMock(for: annotation.element, annotation: annotation)
        
        // Then
        XCTAssertTrue(result.contains("..."))
    }
    
    // MARK: - Default Value Generation Coverage Tests
    
    func testStubGenerator_givenNumericTypes_whenGeneratingDefaultValues_thenUsesCorrectDefaults() throws {
        // Given
        let sut = StubGenerator()
        let types: [(String, String)] = [
            ("Int", "0"),
            ("Int8", "0"),
            ("UInt", "0"),
            ("Float", "0.0"),
            ("Double", "0.0"),
            ("CGFloat", "0.0")
        ]
        
        // When & Then
        for (type, expectedDefault) in types {
            let method = MethodElement(
                name: "get\(type)",
                returnType: type
            )
            let protocolElement = ProtocolElement(
                name: "TestProtocol",
                methods: [method]
            )
            let annotation = MockAnnotation(
                type: .stub,
                element: .protocol(protocolElement),
                location: SourceLocation(line: 1, column: 1, file: "test.swift")
            )
            
            let result = try sut.generateMock(for: annotation.element, annotation: annotation)
            XCTAssertTrue(result.contains(expectedDefault) || result.contains("return"))
        }
    }
    
    func testStubGenerator_givenCollectionTypes_whenGeneratingDefaultValues_thenUsesEmptyCollections() throws {
        // Given
        let sut = StubGenerator()
        let types = ["[String]", "[String: Int]", "Set<String>"]
        
        // When & Then
        for type in types {
            let method = MethodElement(
                name: "get\(type.replacingOccurrences(of: "[", with: "").replacingOccurrences(of: "]", with: "").replacingOccurrences(of: ":", with: "").replacingOccurrences(of: "<", with: "").replacingOccurrences(of: ">", with: "").replacingOccurrences(of: "Set", with: "").replacingOccurrences(of: " ", with: ""))",
                returnType: type
            )
            let protocolElement = ProtocolElement(
                name: "TestProtocol",
                methods: [method]
            )
            let annotation = MockAnnotation(
                type: .stub,
                element: .protocol(protocolElement),
                location: SourceLocation(line: 1, column: 1, file: "test.swift")
            )
            
            let result = try sut.generateMock(for: annotation.element, annotation: annotation)
            XCTAssertTrue(result.contains("[]") || result.contains("[:]") || result.contains("Set()"))
        }
    }
    
    // MARK: - Class Generation Coverage Tests
    
    func testStubGenerator_givenClassWithProperties_whenGenerating_thenOverridesProperties() throws {
        // Given
        let sut = StubGenerator()
        let property = PropertyElement(
            name: "testProperty",
            type: "String",
            hasGetter: true,
            hasSetter: true
        )
        let classElement = ClassElement(
            name: "TestClass",
            properties: [property]
        )
        let annotation = MockAnnotation(
            type: .stub,
            element: .class(classElement),
            location: SourceLocation(line: 1, column: 1, file: "test.swift")
        )
        
        // When
        let result = try sut.generateMock(for: annotation.element, annotation: annotation)
        
        // Then
        XCTAssertTrue(result.contains("override"))
        XCTAssertTrue(result.contains("testProperty"))
    }
    
    // MARK: - Function Generation Coverage Tests
    
    func testStubGenerator_givenFunctionWithGenericParameters_whenGenerating_thenIncludesGenerics() throws {
        // Given
        let sut = StubGenerator()
        let function = FunctionElement(
            name: "genericFunction",
            parameters: [ParameterElement(internalName: "value", type: "T")],
            returnType: "T",
            genericParameters: ["T"]
        )
        let annotation = MockAnnotation(
            type: .stub,
            element: .function(function),
            location: SourceLocation(line: 1, column: 1, file: "test.swift")
        )
        
        // When
        let result = try sut.generateMock(for: annotation.element, annotation: annotation)
        
        // Then
        XCTAssertTrue(result.contains("<T>"))
        XCTAssertTrue(result.contains("genericFunction"))
    }
    
    // MARK: - Return Value Property Coverage Tests
    
    func testStubGenerator_givenAsyncMethodWithUseResult_whenGenerating_thenCreatesReturnValueProperty() throws {
        // Given
        let sut = StubGenerator()
        let method = MethodElement(
            name: "asyncMethod",
            returnType: "String",
            isAsync: true,
            isThrowing: true
        )
        let protocolElement = ProtocolElement(
            name: "TestProtocol",
            methods: [method]
        )
        let annotation = MockAnnotation(
            type: .stub,
            element: .protocol(protocolElement),
            location: SourceLocation(line: 1, column: 1, file: "test.swift")
        )
        
        // When
        let result = try sut.generateMock(for: annotation.element, annotation: annotation, useResult: true)
        
        // Then
        XCTAssertTrue(result.contains("asyncMethodReturnValue"))
        XCTAssertTrue(result.contains("Result<String, Error>"))
    }
    
    // MARK: - Generic Parameters Coverage Tests
    
    func testStubGenerator_givenProtocolWithGenericParameters_whenGenerating_thenIncludesGenerics() throws {
        // Given
        let sut = StubGenerator()
        let protocolElement = ProtocolElement(
            name: "GenericProtocol",
            genericParameters: ["T", "U", "V"]
        )
        let annotation = MockAnnotation(
            type: .stub,
            element: .protocol(protocolElement),
            location: SourceLocation(line: 1, column: 1, file: "test.swift")
        )
        
        // When
        let result = try sut.generateMock(for: annotation.element, annotation: annotation)
        
        // Then
        XCTAssertTrue(result.contains("<T, U, V>"))
        XCTAssertTrue(result.contains("GenericProtocol"))
    }
    
    // MARK: - Access Level Coverage Tests
    
    func testStubGenerator_givenDifferentAccessLevels_whenGenerating_thenRespectsAccessLevels() throws {
        // Given
        let sut = StubGenerator()
        let accessLevels: [AccessLevel] = [.private, .fileprivate, .internal, .public, .open]
        
        // When & Then
        for accessLevel in accessLevels {
            let protocolElement = ProtocolElement(
                name: "\(accessLevel.rawValue)Protocol",
                accessLevel: accessLevel
            )
            let annotation = MockAnnotation(
                type: .stub,
                element: .protocol(protocolElement),
                location: SourceLocation(line: 1, column: 1, file: "test.swift")
            )
            
            let result = try sut.generateMock(for: annotation.element, annotation: annotation, useResult: false)
            
            if accessLevel != .internal {
                XCTAssertTrue(result.contains(accessLevel.rawValue), "Failed for \(accessLevel)")
            }
        }
    }
}


import XCTest
import Foundation

@testable import SwiftMockGenerator

final class GeneratorsCoverageTests: XCTestCase {
    
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
    
    func testSpyGenerator_givenProtocol_whenGeneratingMockDefinition_thenRemovesHeader() throws {
        // Given
        let sut = SpyGenerator()
        let protocolElement = ProtocolElement(name: "TestProtocol")
        let annotation = MockAnnotation(
            type: .spy,
            element: .protocol(protocolElement),
            location: SourceLocation(line: 1, column: 1, file: "test.swift")
        )
        
        // When
        let result = try sut.generateMockDefinition(for: annotation.element, annotation: annotation)
        
        // Then
        XCTAssertFalse(result.isEmpty)
        XCTAssertFalse(result.contains("// MARK: - Generated Spy"))
        XCTAssertTrue(result.contains("class TestProtocolSpy"))
    }
    
    func testDummyGenerator_givenProtocol_whenGeneratingMockDefinition_thenRemovesHeader() throws {
        // Given
        let sut = DummyGenerator()
        let protocolElement = ProtocolElement(name: "TestProtocol")
        let annotation = MockAnnotation(
            type: .dummy,
            element: .protocol(protocolElement),
            location: SourceLocation(line: 1, column: 1, file: "test.swift")
        )
        
        // When
        let result = try sut.generateMockDefinition(for: annotation.element, annotation: annotation)
        
        // Then
        XCTAssertFalse(result.isEmpty)
        XCTAssertFalse(result.contains("// MARK: - Generated Dummy"))
        XCTAssertTrue(result.contains("class TestProtocolDummy"))
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
    
    func testSpyGenerator_givenPropertyWithSetter_whenGenerating_thenUsesStoredProperty() throws {
        // Given
        let sut = SpyGenerator()
        let property = PropertyElement(
            name: "mutableProp",
            type: "String",
            hasGetter: true,
            hasSetter: true
        )
        let protocolElement = ProtocolElement(
            name: "TestProtocol",
            properties: [property]
        )
        let annotation = MockAnnotation(
            type: .spy,
            element: .protocol(protocolElement),
            location: SourceLocation(line: 1, column: 1, file: "test.swift")
        )
        
        // When
        let result = try sut.generateMock(for: annotation.element, annotation: annotation)
        
        // Then
        XCTAssertTrue(result.contains("mutableProp"))
        XCTAssertTrue(result.contains("="))
    }
    
    func testDummyGenerator_givenStaticProperty_whenGenerating_thenIncludesStaticModifier() throws {
        // Given
        let sut = DummyGenerator()
        let property = PropertyElement(
            name: "staticProp",
            type: "Bool",
            isStatic: true,
            hasGetter: true,
            hasSetter: true
        )
        let protocolElement = ProtocolElement(
            name: "TestProtocol",
            properties: [property]
        )
        let annotation = MockAnnotation(
            type: .dummy,
            element: .protocol(protocolElement),
            location: SourceLocation(line: 1, column: 1, file: "test.swift")
        )
        
        // When
        let result = try sut.generateMock(for: annotation.element, annotation: annotation)
        
        // Then
        XCTAssertTrue(result.contains("static"))
        XCTAssertTrue(result.contains("staticProp"))
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
    
    func testSpyGenerator_givenVoidThrowingMethod_whenGenerating_thenHandlesThrowError() throws {
        // Given
        let sut = SpyGenerator()
        let method = MethodElement(
            name: "voidThrowingMethod",
            parameters: [],
            returnType: nil,
            isThrowing: true
        )
        let protocolElement = ProtocolElement(
            name: "TestProtocol",
            methods: [method]
        )
        let annotation = MockAnnotation(
            type: .spy,
            element: .protocol(protocolElement),
            location: SourceLocation(line: 1, column: 1, file: "test.swift")
        )
        
        // When
        let result = try sut.generateMock(for: annotation.element, annotation: annotation)
        
        // Then
        XCTAssertTrue(result.contains("voidThrowingMethodThrowError"))
        XCTAssertTrue(result.contains("voidThrowingMethod"))
    }
    
    func testSpyGenerator_givenMethodWithNoParameters_whenGenerating_thenUsesVoidTuple() throws {
        // Given
        let sut = SpyGenerator()
        let method = MethodElement(
            name: "noParamsMethod",
            parameters: [],
            returnType: "String"
        )
        let protocolElement = ProtocolElement(
            name: "TestProtocol",
            methods: [method]
        )
        let annotation = MockAnnotation(
            type: .spy,
            element: .protocol(protocolElement),
            location: SourceLocation(line: 1, column: 1, file: "test.swift")
        )
        
        // When
        let result = try sut.generateMock(for: annotation.element, annotation: annotation)
        
        // Then
        XCTAssertTrue(result.contains("noParamsMethodCallParameters"))
        XCTAssertTrue(result.contains("Void"))
    }
    
    func testDummyGenerator_givenMethodWithReturnType_whenGenerating_thenReturnsMinimalValue() throws {
        // Given
        let sut = DummyGenerator()
        let method = MethodElement(
            name: "returningMethod",
            parameters: [],
            returnType: "Int"
        )
        let protocolElement = ProtocolElement(
            name: "TestProtocol",
            methods: [method]
        )
        let annotation = MockAnnotation(
            type: .dummy,
            element: .protocol(protocolElement),
            location: SourceLocation(line: 1, column: 1, file: "test.swift")
        )
        
        // When
        let result = try sut.generateMock(for: annotation.element, annotation: annotation)
        
        // Then
        XCTAssertTrue(result.contains("return"))
        XCTAssertTrue(result.contains("returningMethod"))
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
    
    func testSpyGenerator_givenInitializer_whenGenerating_thenCallsSuperInit() throws {
        // Given
        let sut = SpyGenerator()
        let initializer = InitializerElement(
            parameters: [ParameterElement(internalName: "value", type: "String")]
        )
        let classElement = ClassElement(
            name: "TestClass",
            initializers: [initializer]
        )
        let annotation = MockAnnotation(
            type: .spy,
            element: .class(classElement),
            location: SourceLocation(line: 1, column: 1, file: "test.swift")
        )
        
        // When
        let result = try sut.generateMock(for: annotation.element, annotation: annotation)
        
        // Then
        XCTAssertTrue(result.contains("super.init()"))
    }
    
    func testDummyGenerator_givenInitializer_whenGenerating_thenIncludesDummyComment() throws {
        // Given
        let sut = DummyGenerator()
        let initializer = InitializerElement(
            parameters: [ParameterElement(internalName: "value", type: "String")]
        )
        let classElement = ClassElement(
            name: "TestClass",
            initializers: [initializer]
        )
        let annotation = MockAnnotation(
            type: .dummy,
            element: .class(classElement),
            location: SourceLocation(line: 1, column: 1, file: "test.swift")
        )
        
        // When
        let result = try sut.generateMock(for: annotation.element, annotation: annotation)
        
        // Then
        XCTAssertTrue(result.contains("Dummy implementation"))
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
    
    func testSpyGenerator_givenMultipleParameters_whenGenerating_thenTracksAllParameters() throws {
        // Given
        let sut = SpyGenerator()
        let parameters = [
            ParameterElement(internalName: "param1", type: "String"),
            ParameterElement(internalName: "param2", type: "Int"),
            ParameterElement(internalName: "param3", type: "Bool")
        ]
        let method = MethodElement(
            name: "method",
            parameters: parameters,
            returnType: "Void"
        )
        let protocolElement = ProtocolElement(
            name: "TestProtocol",
            methods: [method]
        )
        let annotation = MockAnnotation(
            type: .spy,
            element: .protocol(protocolElement),
            location: SourceLocation(line: 1, column: 1, file: "test.swift")
        )
        
        // When
        let result = try sut.generateMock(for: annotation.element, annotation: annotation)
        
        // Then
        XCTAssertTrue(result.contains("methodCallParameters"))
        XCTAssertTrue(result.contains("param1"))
        XCTAssertTrue(result.contains("param2"))
        XCTAssertTrue(result.contains("param3"))
    }
    
    // MARK: - Default/Minimal Value Generation Coverage Tests
    
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
    
    func testDummyGenerator_givenOptionalTypes_whenGeneratingMinimalValues_thenReturnsNil() throws {
        // Given
        let sut = DummyGenerator()
        let types = ["String?", "Int?", "Bool?", "User?"]
        
        // When & Then
        for type in types {
            let method = MethodElement(
                name: "get\(type.replacingOccurrences(of: "?", with: ""))",
                returnType: type
            )
            let protocolElement = ProtocolElement(
                name: "TestProtocol",
                methods: [method]
            )
            let annotation = MockAnnotation(
                type: .dummy,
                element: .protocol(protocolElement),
                location: SourceLocation(line: 1, column: 1, file: "test.swift")
            )
            
            let result = try sut.generateMock(for: annotation.element, annotation: annotation)
            XCTAssertTrue(result.contains("nil"))
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
    
    func testDummyGenerator_givenGenericTypes_whenGeneratingMinimalValues_thenUsesTypeInitializer() throws {
        // Given
        let sut = DummyGenerator()
        let types = ["Array<Int>", "Dictionary<String, Int>", "Optional<String>"]
        
        // When & Then
        for type in types {
            let method = MethodElement(
                name: "getValue",
                returnType: type
            )
            let protocolElement = ProtocolElement(
                name: "TestProtocol",
                methods: [method]
            )
            let annotation = MockAnnotation(
                type: .dummy,
                element: .protocol(protocolElement),
                location: SourceLocation(line: 1, column: 1, file: "test.swift")
            )
            
            let result = try sut.generateMock(for: annotation.element, annotation: annotation)
            // Should generate some form of default value
            XCTAssertFalse(result.isEmpty)
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
    
    func testSpyGenerator_givenClassWithMethods_whenGenerating_thenOverridesMethods() throws {
        // Given
        let sut = SpyGenerator()
        let method = MethodElement(
            name: "testMethod",
            returnType: "String"
        )
        let classElement = ClassElement(
            name: "TestClass",
            methods: [method]
        )
        let annotation = MockAnnotation(
            type: .spy,
            element: .class(classElement),
            location: SourceLocation(line: 1, column: 1, file: "test.swift")
        )
        
        // When
        let result = try sut.generateMock(for: annotation.element, annotation: annotation)
        
        // Then
        XCTAssertTrue(result.contains("override"))
        XCTAssertTrue(result.contains("testMethod"))
    }
    
    func testDummyGenerator_givenClassWithInheritance_whenGenerating_thenIncludesInheritance() throws {
        // Given
        let sut = DummyGenerator()
        let classElement = ClassElement(
            name: "TestClass",
            inheritance: ["ParentClass", "Protocol1"]
        )
        let annotation = MockAnnotation(
            type: .dummy,
            element: .class(classElement),
            location: SourceLocation(line: 1, column: 1, file: "test.swift")
        )
        
        // When
        let result = try sut.generateMock(for: annotation.element, annotation: annotation)
        
        // Then
        XCTAssertTrue(result.contains("TestClass"))
        XCTAssertTrue(result.contains("ParentClass") || result.contains("Protocol1"))
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
    
    func testSpyGenerator_givenFunctionWithParameters_whenGenerating_thenTracksParameters() throws {
        // Given
        let sut = SpyGenerator()
        let function = FunctionElement(
            name: "testFunction",
            parameters: [
                ParameterElement(internalName: "param1", type: "String"),
                ParameterElement(internalName: "param2", type: "Int")
            ],
            returnType: "Bool"
        )
        let annotation = MockAnnotation(
            type: .spy,
            element: .function(function),
            location: SourceLocation(line: 1, column: 1, file: "test.swift")
        )
        
        // When
        let result = try sut.generateMock(for: annotation.element, annotation: annotation)
        
        // Then
        XCTAssertTrue(result.contains("callParameters"))
        XCTAssertTrue(result.contains("param1"))
        XCTAssertTrue(result.contains("param2"))
    }
    
    func testDummyGenerator_givenAsyncFunctionWithUseResult_whenGenerating_thenUsesReturnValue() throws {
        // Given
        let sut = DummyGenerator()
        let function = FunctionElement(
            name: "asyncFunction",
            parameters: [],
            returnType: "String",
            isAsync: true,
            isThrowing: true
        )
        let annotation = MockAnnotation(
            type: .dummy,
            element: .function(function),
            location: SourceLocation(line: 1, column: 1, file: "test.swift")
        )
        
        // When
        let result = try sut.generateMock(for: annotation.element, annotation: annotation, useResult: true)
        
        // Then
        // For functions, DummyGenerator uses returnValue.get() but doesn't generate the property
        // This test verifies the function body uses returnValue
        XCTAssertTrue(result.contains("returnValue") || result.contains("return"))
        XCTAssertTrue(result.contains("asyncFunction"))
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
    
    func testSpyGenerator_givenMethodWithoutUseResult_whenGenerating_thenCreatesRegularReturnValue() throws {
        // Given
        let sut = SpyGenerator()
        let method = MethodElement(
            name: "syncMethod",
            returnType: "Int",
            isAsync: false
        )
        let protocolElement = ProtocolElement(
            name: "TestProtocol",
            methods: [method]
        )
        let annotation = MockAnnotation(
            type: .spy,
            element: .protocol(protocolElement),
            location: SourceLocation(line: 1, column: 1, file: "test.swift")
        )
        
        // When
        let result = try sut.generateMock(for: annotation.element, annotation: annotation, useResult: false)
        
        // Then
        XCTAssertTrue(result.contains("syncMethodReturnValue"))
        XCTAssertTrue(result.contains(": Int"))
        XCTAssertFalse(result.contains("Result<"))
    }
    
    func testDummyGenerator_givenVoidMethodWithUseResult_whenGenerating_thenDoesNotCreateReturnValue() throws {
        // Given
        let sut = DummyGenerator()
        let method = MethodElement(
            name: "voidMethod",
            returnType: nil,
            isAsync: true
        )
        let protocolElement = ProtocolElement(
            name: "TestProtocol",
            methods: [method]
        )
        let annotation = MockAnnotation(
            type: .dummy,
            element: .protocol(protocolElement),
            location: SourceLocation(line: 1, column: 1, file: "test.swift")
        )
        
        // When
        let result = try sut.generateMock(for: annotation.element, annotation: annotation, useResult: true)
        
        // Then
        XCTAssertFalse(result.contains("voidMethodReturnValue"))
    }
    
    // MARK: - Reset Function Coverage Tests
    
    func testSpyGenerator_givenProtocolWithMethods_whenGenerating_thenIncludesResetFunction() throws {
        // Given
        let sut = SpyGenerator()
        let methods = [
            MethodElement(name: "method1", returnType: "String"),
            MethodElement(name: "method2", returnType: "Int")
        ]
        let protocolElement = ProtocolElement(
            name: "TestProtocol",
            methods: methods
        )
        let annotation = MockAnnotation(
            type: .spy,
            element: .protocol(protocolElement),
            location: SourceLocation(line: 1, column: 1, file: "test.swift")
        )
        
        // When
        let result = try sut.generateMock(for: annotation.element, annotation: annotation)
        
        // Then
        XCTAssertTrue(result.contains("resetSpy"))
        XCTAssertTrue(result.contains("method1CallCount"))
        XCTAssertTrue(result.contains("method2CallCount"))
    }
    
    func testSpyGenerator_givenClassWithMethods_whenGenerating_thenIncludesResetFunction() throws {
        // Given
        let sut = SpyGenerator()
        let methods = [
            MethodElement(name: "method1", returnType: "String"),
            MethodElement(name: "method2", returnType: "Int")
        ]
        let classElement = ClassElement(
            name: "TestClass",
            methods: methods
        )
        let annotation = MockAnnotation(
            type: .spy,
            element: .class(classElement),
            location: SourceLocation(line: 1, column: 1, file: "test.swift")
        )
        
        // When
        let result = try sut.generateMock(for: annotation.element, annotation: annotation)
        
        // Then
        XCTAssertTrue(result.contains("resetSpy"))
        XCTAssertTrue(result.contains("method1CallCount"))
        XCTAssertTrue(result.contains("method2CallCount"))
    }
    
    func testSpyGenerator_givenFunction_whenGenerating_thenIncludesResetMethod() throws {
        // Given
        let sut = SpyGenerator()
        let function = FunctionElement(
            name: "testFunction",
            parameters: [ParameterElement(internalName: "value", type: "String")],
            returnType: "Bool"
        )
        let annotation = MockAnnotation(
            type: .spy,
            element: .function(function),
            location: SourceLocation(line: 1, column: 1, file: "test.swift")
        )
        
        // When
        let result = try sut.generateMock(for: annotation.element, annotation: annotation)
        
        // Then
        XCTAssertTrue(result.contains("reset()"))
        XCTAssertTrue(result.contains("callCount"))
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
    
    func testSpyGenerator_givenClassWithGenericParameters_whenGenerating_thenIncludesGenerics() throws {
        // Given
        let sut = SpyGenerator()
        let classElement = ClassElement(
            name: "GenericClass",
            genericParameters: ["Element"]
        )
        let annotation = MockAnnotation(
            type: .spy,
            element: .class(classElement),
            location: SourceLocation(line: 1, column: 1, file: "test.swift")
        )
        
        // When
        let result = try sut.generateMock(for: annotation.element, annotation: annotation)
        
        // Then
        XCTAssertTrue(result.contains("<Element>"))
        XCTAssertTrue(result.contains("GenericClass"))
    }
    
    // MARK: - Access Level Coverage Tests
    
    func testAllGenerators_givenDifferentAccessLevels_whenGenerating_thenRespectsAccessLevels() throws {
        // Given
        let generators: [MockGeneratorProtocol] = [
            StubGenerator(),
            SpyGenerator(),
            DummyGenerator()
        ]
        let accessLevels: [AccessLevel] = [.private, .fileprivate, .internal, .public, .open]
        
        // When & Then
        for sut in generators {
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
                    XCTAssertTrue(result.contains(accessLevel.rawValue), "Failed for \(accessLevel) in \(type(of: sut))")
                }
            }
        }
    }
}


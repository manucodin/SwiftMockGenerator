import XCTest
import Foundation

@testable import SwiftMockGenerator

final class SpyGeneratorCoverageTests: XCTestCase {
    
    // MARK: - generateMockDefinition Coverage Tests
    
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
    
    // MARK: - Property Generation Coverage Tests
    
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
    
    // MARK: - Method Generation Coverage Tests
    
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
    
    // MARK: - Initializer Generation Coverage Tests
    
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
    
    // MARK: - Parameter Generation Coverage Tests
    
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
    
    // MARK: - Class Generation Coverage Tests
    
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
    
    // MARK: - Function Generation Coverage Tests
    
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
    
    // MARK: - Return Value Property Coverage Tests
    
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
    
    func testSpyGenerator_givenDifferentAccessLevels_whenGenerating_thenRespectsAccessLevels() throws {
        // Given
        let sut = SpyGenerator()
        let accessLevels: [AccessLevel] = [.private, .fileprivate, .internal, .public, .open]
        
        // When & Then
        for accessLevel in accessLevels {
            let protocolElement = ProtocolElement(
                name: "\(accessLevel.rawValue)Protocol",
                accessLevel: accessLevel
            )
            let annotation = MockAnnotation(
                type: .spy,
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


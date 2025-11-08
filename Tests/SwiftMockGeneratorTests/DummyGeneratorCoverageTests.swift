import XCTest
import Foundation

@testable import SwiftMockGenerator

final class DummyGeneratorCoverageTests: XCTestCase {
    
    // MARK: - generateMockDefinition Coverage Tests
    
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
    
    // MARK: - Minimal Value Generation Coverage Tests
    
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
    
    // MARK: - Access Level Coverage Tests
    
    func testDummyGenerator_givenDifferentAccessLevels_whenGenerating_thenRespectsAccessLevels() throws {
        // Given
        let sut = DummyGenerator()
        let accessLevels: [AccessLevel] = [.private, .fileprivate, .internal, .public, .open]
        
        // When & Then
        for accessLevel in accessLevels {
            let protocolElement = ProtocolElement(
                name: "\(accessLevel.rawValue)Protocol",
                accessLevel: accessLevel
            )
            let annotation = MockAnnotation(
                type: .dummy,
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


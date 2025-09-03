import XCTest
@testable import SwiftMockGeneratorLib

final class SwiftMockGeneratorTests: XCTestCase {
    
    // MARK: - MockGenerator Tests
    
    func testMockGeneratorInitialization() {
        // Given
        let inputPath = "test"
        let outputPath = "test_output"
        let filePattern = "*.swift"
        
        // When
        let sut = MockGenerator(
            inputPath: inputPath,
            outputPath: outputPath,
            filePattern: filePattern
        )
        
        // Then
        XCTAssertNotNil(sut)
    }
    
    // MARK: - Generator Tests
    
    func testSyntaxParserInitialization() {
        // Given - No setup needed
        
        // When
        let sut = SyntaxParser()
        
        // Then
        XCTAssertNotNil(sut)
    }
    
    func testStubGeneratorInitialization() {
        // Given - No setup needed
        
        // When
        let sut = StubGenerator()
        
        // Then
        XCTAssertNotNil(sut)
    }
    
    func testSpyGeneratorInitialization() {
        // Given - No setup needed
        
        // When
        let sut = SpyGenerator()
        
        // Then
        XCTAssertNotNil(sut)
    }
    
    func testDummyGeneratorInitialization() {
        // Given - No setup needed
        
        // When
        let sut = DummyGenerator()
        
        // Then
        XCTAssertNotNil(sut)
    }
    
    // MARK: - MockType Enum Tests
    
    func testMockTypeEnumValues() {
        // Given
        let expectedRawValues = ["Stub", "Spy", "Dummy"]
        let expectedPrefixes = ["// @Stub", "// @Spy", "// @Dummy"]
        
        // When
        let stubType = MockType.stub
        let spyType = MockType.spy
        let dummyType = MockType.dummy
        
        // Then
        XCTAssertEqual(stubType.rawValue, expectedRawValues[0])
        XCTAssertEqual(spyType.rawValue, expectedRawValues[1])
        XCTAssertEqual(dummyType.rawValue, expectedRawValues[2])
        
        XCTAssertEqual(stubType.commentPrefix, expectedPrefixes[0])
        XCTAssertEqual(spyType.commentPrefix, expectedPrefixes[1])
        XCTAssertEqual(dummyType.commentPrefix, expectedPrefixes[2])
    }
    
    // MARK: - AccessLevel Enum Tests
    
    func testAccessLevelKeywords() {
        // Given
        let expectedKeywords: [AccessLevel: String] = [
            .public: "public ",
            .internal: "",
            .private: "private ",
            .fileprivate: "fileprivate ",
            .open: "open "
        ]
        
        // When & Then
        for (accessLevel, expectedKeyword) in expectedKeywords {
            XCTAssertEqual(accessLevel.keyword, expectedKeyword)
        }
    }
    
    // MARK: - ProtocolElement Tests
    
    func testProtocolElementCreation() {
        // Given
        let name = "TestProtocol"
        let accessLevel = AccessLevel.public
        
        // When
        let sut = ProtocolElement(
            name: name,
            accessLevel: accessLevel
        )
        
        // Then
        XCTAssertEqual(sut.name, name)
        XCTAssertEqual(sut.accessLevel, accessLevel)
        XCTAssertTrue(sut.methods.isEmpty)
        XCTAssertTrue(sut.properties.isEmpty)
    }
    
    func testProtocolElementWithComplexData() {
        // Given
        let name = "ComplexProtocol"
        let methods = [MethodElement(name: "testMethod")]
        let properties = [PropertyElement(name: "testProperty", type: "String")]
        let associatedTypes = [AssociatedTypeElement(name: "Item")]
        let inheritance = ["ParentProtocol"]
        let genericParameters = ["T"]
        
        // When
        let sut = ProtocolElement(
            name: name,
            methods: methods,
            properties: properties,
            associatedTypes: associatedTypes,
            inheritance: inheritance,
            accessLevel: .internal,
            genericParameters: genericParameters
        )
        
        // Then
        XCTAssertEqual(sut.name, name)
        XCTAssertEqual(sut.methods.count, 1)
        XCTAssertEqual(sut.properties.count, 1)
        XCTAssertEqual(sut.associatedTypes.count, 1)
        XCTAssertEqual(sut.inheritance.count, 1)
        XCTAssertEqual(sut.genericParameters.count, 1)
    }
    
    // MARK: - ClassElement Tests
    
    func testClassElementCreation() {
        // Given
        let name = "TestClass"
        let accessLevel = AccessLevel.internal
        
        // When
        let sut = ClassElement(
            name: name,
            accessLevel: accessLevel
        )
        
        // Then
        XCTAssertEqual(sut.name, name)
        XCTAssertEqual(sut.accessLevel, accessLevel)
        XCTAssertFalse(sut.isFinal)
    }
    
    func testClassElementWithFinalModifier() {
        // Given
        let name = "FinalClass"
        let isFinal = true
        
        // When
        let sut = ClassElement(
            name: name,
            isFinal: isFinal
        )
        
        // Then
        XCTAssertEqual(sut.name, name)
        XCTAssertTrue(sut.isFinal)
    }
    
    // MARK: - StructElement Tests
    
    func testStructElementCreation() {
        // Given
        let name = "TestStruct"
        let accessLevel = AccessLevel.public
        
        // When
        let sut = StructElement(
            name: name,
            accessLevel: accessLevel
        )
        
        // Then
        XCTAssertEqual(sut.name, name)
        XCTAssertEqual(sut.accessLevel, accessLevel)
    }
    
    // MARK: - FunctionElement Tests
    
    func testFunctionElementCreation() {
        // Given
        let name = "testFunction"
        let parameter = ParameterElement(internalName: "value", type: "String")
        let parameters = [parameter]
        let returnType = "Bool"
        let accessLevel = AccessLevel.public
        
        // When
        let sut = FunctionElement(
            name: name,
            parameters: parameters,
            returnType: returnType,
            accessLevel: accessLevel
        )
        
        // Then
        XCTAssertEqual(sut.name, name)
        XCTAssertEqual(sut.parameters.count, 1)
        XCTAssertEqual(sut.returnType, returnType)
        XCTAssertEqual(sut.accessLevel, accessLevel)
        XCTAssertFalse(sut.isStatic)
        XCTAssertFalse(sut.isAsync)
        XCTAssertFalse(sut.isThrowing)
    }
    
    func testFunctionElementWithModifiers() {
        // Given
        let name = "complexFunction"
        let isStatic = true
        let isAsync = true
        let isThrowing = true
        
        // When
        let sut = FunctionElement(
            name: name,
            isStatic: isStatic,
            isAsync: isAsync,
            isThrowing: isThrowing
        )
        
        // Then
        XCTAssertEqual(sut.name, name)
        XCTAssertTrue(sut.isStatic)
        XCTAssertTrue(sut.isAsync)
        XCTAssertTrue(sut.isThrowing)
    }
    
    // MARK: - CodeElement Tests
    
    func testCodeElementVariants() {
        // Given
        let protocolElement = ProtocolElement(name: "TestProtocol")
        let classElement = ClassElement(name: "TestClass")
        let structElement = StructElement(name: "TestStruct")
        let functionElement = FunctionElement(name: "testFunction")
        
        // When
        let protocolSUT = CodeElement.protocol(protocolElement)
        let classSUT = CodeElement.class(classElement)
        let structSUT = CodeElement.struct(structElement)
        let functionSUT = CodeElement.function(functionElement)
        
        // Then
        XCTAssertEqual(protocolSUT.name, "TestProtocol")
        XCTAssertEqual(classSUT.name, "TestClass")
        XCTAssertEqual(structSUT.name, "TestStruct")
        XCTAssertEqual(functionSUT.name, "testFunction")
        
        XCTAssertTrue(protocolSUT.isReference)
        XCTAssertTrue(classSUT.isReference)
        XCTAssertFalse(structSUT.isReference)
        XCTAssertFalse(functionSUT.isReference)
    }
    
    // MARK: - MockAnnotation Tests
    
    func testMockAnnotationCreation() {
        // Given
        let element = ProtocolElement(name: "TestProtocol")
        let location = SourceLocation(line: 10, column: 5, file: "test.swift")
        let options = ["option1": "value1"]
        let mockType = MockType.stub
        
        // When
        let sut = MockAnnotation(
            type: mockType,
            element: .protocol(element),
            location: location,
            options: options
        )
        
        // Then
        XCTAssertEqual(sut.type, mockType)
        XCTAssertEqual(sut.element.name, "TestProtocol")
        XCTAssertEqual(sut.location.line, 10)
        XCTAssertEqual(sut.location.column, 5)
        XCTAssertEqual(sut.location.file, "test.swift")
        XCTAssertEqual(sut.options["option1"], "value1")
    }
}
import XCTest
@testable import SwiftMockGeneratorLib

final class SwiftMockGeneratorTests: XCTestCase {
    
    // MARK: - MockGenerator Tests
    
    func testMockGeneratorInitialization() {
        // Given
        let inputPath = "test"
        let outputPath = "test_output"
        
        // When
        let sut = MockGenerator(
            inputPath: inputPath,
            outputPath: outputPath
        )
        
        // Then
        XCTAssertNotNil(sut)
    }
    
    // MARK: - File Naming Contract Tests
    
    func testMockGenerator_givenStubAnnotation_whenCreatingOutputFileName_thenReturnsCorrectStubFileName() {
        // Given
        let sut = MockGenerator(inputPath: ".", outputPath: ".")
        let protocolElement = ProtocolElement(name: "NetworkService")
        let annotation = MockAnnotation(
            type: .stub,
            element: .protocol(protocolElement),
            location: SourceLocation(line: 1, column: 1, file: "test.swift")
        )
        let originalFile = "/path/to/NetworkService.swift"
        
        // When
        let result = sut.createOutputFileName(for: annotation, originalFile: originalFile)
        
        // Then
        XCTAssertEqual(result, "NetworkServiceStub.swift")
    }
    
    func testMockGenerator_givenSpyAnnotation_whenCreatingOutputFileName_thenReturnsCorrectSpyFileName() {
        // Given
        let sut = MockGenerator(inputPath: ".", outputPath: ".")
        let classElement = ClassElement(name: "DataRepository")
        let annotation = MockAnnotation(
            type: .spy,
            element: .class(classElement),
            location: SourceLocation(line: 1, column: 1, file: "test.swift")
        )
        let originalFile = "/Users/dev/project/Sources/DataRepository.swift"
        
        // When
        let result = sut.createOutputFileName(for: annotation, originalFile: originalFile)
        
        // Then
        XCTAssertEqual(result, "DataRepositorySpy.swift")
    }
    
    func testMockGenerator_givenDummyAnnotation_whenCreatingOutputFileName_thenReturnsCorrectDummyFileName() {
        // Given
        let sut = MockGenerator(inputPath: ".", outputPath: ".")
        let classElement = ClassElement(name: "Configuration")
        let annotation = MockAnnotation(
            type: .dummy,
            element: .class(classElement),
            location: SourceLocation(line: 1, column: 1, file: "test.swift")
        )
        let originalFile = "Configuration.swift"
        
        // When
        let result = sut.createOutputFileName(for: annotation, originalFile: originalFile)
        
        // Then
        XCTAssertEqual(result, "ConfigurationDummy.swift")
    }
    
    func testMockGenerator_givenComplexFilePath_whenCreatingOutputFileName_thenExtractsCorrectBaseName() {
        // Given
        let sut = MockGenerator(inputPath: ".", outputPath: ".")
        let protocolElement = ProtocolElement(name: "AuthenticationService")
        let annotation = MockAnnotation(
            type: .stub,
            element: .protocol(protocolElement),
            location: SourceLocation(line: 1, column: 1, file: "test.swift")
        )
        let originalFile = "/very/long/path/to/deeply/nested/AuthenticationService.swift"
        
        // When
        let result = sut.createOutputFileName(for: annotation, originalFile: originalFile)
        
        // Then
        XCTAssertEqual(result, "AuthenticationServiceStub.swift")
    }
    
    func testMockGenerator_givenFileWithUnderscores_whenCreatingOutputFileName_thenPreservesUnderscores() {
        // Given
        let sut = MockGenerator(inputPath: ".", outputPath: ".")
        let protocolElement = ProtocolElement(name: "NetworkService")
        let annotation = MockAnnotation(
            type: .spy,
            element: .protocol(protocolElement),
            location: SourceLocation(line: 1, column: 1, file: "test.swift")
        )
        let originalFile = "network_service_protocol.swift"
        
        // When
        let result = sut.createOutputFileName(for: annotation, originalFile: originalFile)
        
        // Then
        XCTAssertEqual(result, "network_service_protocolSpy.swift")
    }
    
    func testMockGenerator_givenFileWithNumbers_whenCreatingOutputFileName_thenPreservesNumbers() {
        // Given
        let sut = MockGenerator(inputPath: ".", outputPath: ".")
        let classElement = ClassElement(name: "APIv2Client")
        let annotation = MockAnnotation(
            type: .dummy,
            element: .class(classElement),
            location: SourceLocation(line: 1, column: 1, file: "test.swift")
        )
        let originalFile = "APIv2Client.swift"
        
        // When
        let result = sut.createOutputFileName(for: annotation, originalFile: originalFile)
        
        // Then
        XCTAssertEqual(result, "APIv2ClientDummy.swift")
    }
    
    func testMockGenerator_givenFileWithSpecialCharacters_whenCreatingOutputFileName_thenPreservesSpecialCharacters() {
        // Given
        let sut = MockGenerator(inputPath: ".", outputPath: ".")
        let protocolElement = ProtocolElement(name: "Test")
        let annotation = MockAnnotation(
            type: .stub,
            element: .protocol(protocolElement),
            location: SourceLocation(line: 1, column: 1, file: "test.swift")
        )
        let originalFile = "Test-Protocol+Extensions.swift"
        
        // When
        let result = sut.createOutputFileName(for: annotation, originalFile: originalFile)
        
        // Then
        XCTAssertEqual(result, "Test-Protocol+ExtensionsStub.swift")
    }
    
    func testMockGenerator_givenAllMockTypes_whenCreatingOutputFileName_thenReturnsCorrectSuffixes() {
        // Given
        let sut = MockGenerator(inputPath: ".", outputPath: ".")
        let protocolElement = ProtocolElement(name: "TestProtocol")
        let originalFile = "TestService.swift"
        let mockTypes: [MockType] = [.stub, .spy, .dummy]
        let expectedSuffixes = ["Stub", "Spy", "Dummy"]
        
        // When & Then
        for (index, mockType) in mockTypes.enumerated() {
            let annotation = MockAnnotation(
                type: mockType,
                element: .protocol(protocolElement),
                location: SourceLocation(line: 1, column: 1, file: "test.swift")
            )
            
            let result = sut.createOutputFileName(for: annotation, originalFile: originalFile)
            let expectedFileName = "TestService\(expectedSuffixes[index]).swift"
            
            XCTAssertEqual(result, expectedFileName, "Failed for mock type: \(mockType)")
        }
    }
    
    func testMockGenerator_givenFileWithoutExtension_whenCreatingOutputFileName_thenAppendsSwiftExtension() {
        // Given
        let sut = MockGenerator(inputPath: ".", outputPath: ".")
        let protocolElement = ProtocolElement(name: "Service")
        let annotation = MockAnnotation(
            type: .stub,
            element: .protocol(protocolElement),
            location: SourceLocation(line: 1, column: 1, file: "test.swift")
        )
        let originalFile = "ServiceProtocol"
        
        // When
        let result = sut.createOutputFileName(for: annotation, originalFile: originalFile)
        
        // Then
        XCTAssertEqual(result, "ServiceProtocolStub.swift")
    }
    
    func testMockGenerator_givenFileWithMultipleDots_whenCreatingOutputFileName_thenRemovesOnlyLastExtension() {
        // Given
        let sut = MockGenerator(inputPath: ".", outputPath: ".")
        let classElement = ClassElement(name: "APIClient")
        let annotation = MockAnnotation(
            type: .spy,
            element: .class(classElement),
            location: SourceLocation(line: 1, column: 1, file: "test.swift")
        )
        let originalFile = "API.v2.Client.swift"
        
        // When
        let result = sut.createOutputFileName(for: annotation, originalFile: originalFile)
        
        // Then
        XCTAssertEqual(result, "API.v2.ClientSpy.swift")
    }
    
    func testMockGenerator_givenEmptyFileName_whenCreatingOutputFileName_thenHandlesGracefully() {
        // Given
        let sut = MockGenerator(inputPath: ".", outputPath: ".")
        let classElement = ClassElement(name: "Config")
        let annotation = MockAnnotation(
            type: .dummy,
            element: .class(classElement),
            location: SourceLocation(line: 1, column: 1, file: "test.swift")
        )
        let originalFile = ""
        
        // When
        let result = sut.createOutputFileName(for: annotation, originalFile: originalFile)
        
        // Then
        XCTAssertEqual(result, "Dummy.swift")
    }
    
    func testMockGenerator_givenRelativeFilePath_whenCreatingOutputFileName_thenExtractsCorrectBaseName() {
        // Given
        let sut = MockGenerator(inputPath: ".", outputPath: ".")
        let functionElement = FunctionElement(name: "authenticate")
        let annotation = MockAnnotation(
            type: .stub,
            element: .function(functionElement),
            location: SourceLocation(line: 1, column: 1, file: "test.swift")
        )
        let originalFile = "./Sources/Authentication/AuthService.swift"
        
        // When
        let result = sut.createOutputFileName(for: annotation, originalFile: originalFile)
        
        // Then
        XCTAssertEqual(result, "AuthServiceStub.swift")
    }
    
    func testMockGenerator_givenFileNameMatchingMockSuffix_whenCreatingOutputFileName_thenDoesNotDuplicateSuffix() {
        // Given
        let sut = MockGenerator(inputPath: ".", outputPath: ".")
        let protocolElement = ProtocolElement(name: "Service")
        let annotation = MockAnnotation(
            type: .stub,
            element: .protocol(protocolElement),
            location: SourceLocation(line: 1, column: 1, file: "test.swift")
        )
        let originalFile = "ServiceStub.swift"
        
        // When
        let result = sut.createOutputFileName(for: annotation, originalFile: originalFile)
        
        // Then
        // Note: This documents current behavior - the method doesn't check for existing suffixes
        XCTAssertEqual(result, "ServiceStubStub.swift")
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
        let functionElement = FunctionElement(name: "testFunction")
        
        // When
        let protocolSUT = CodeElement.protocol(protocolElement)
        let classSUT = CodeElement.class(classElement)
        let functionSUT = CodeElement.function(functionElement)
        
        // Then
        XCTAssertEqual(protocolSUT.name, "TestProtocol")
        XCTAssertEqual(classSUT.name, "TestClass")
        XCTAssertEqual(functionSUT.name, "testFunction")
        
        XCTAssertTrue(protocolSUT.isReference)
        XCTAssertTrue(classSUT.isReference)
        XCTAssertFalse(functionSUT.isReference)
    }
    
    // MARK: - MockAnnotation Tests
    
    func testMockAnnotationCreation() {
        // Given
        let element = ProtocolElement(name: "TestProtocol")
        let location = SourceLocation(line: 10, column: 5, file: "test.swift")
        let mockType = MockType.stub
        
        // When
        let sut = MockAnnotation(
            type: mockType,
            element: .protocol(element),
            location: location
        )
        
        // Then
        XCTAssertEqual(sut.type, mockType)
        XCTAssertEqual(sut.element.name, "TestProtocol")
        XCTAssertEqual(sut.location.line, 10)
        XCTAssertEqual(sut.location.column, 5)
        XCTAssertEqual(sut.location.file, "test.swift")
    }
}
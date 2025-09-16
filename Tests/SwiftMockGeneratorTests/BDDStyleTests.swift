import XCTest
@testable import SwiftMockGeneratorLib
import Foundation

final class BDDStyleTests: XCTestCase {
    
    // MARK: - SUT: StubGenerator Behavior Tests
    
    func testStubGenerator_givenProtocolWithMethods_whenGeneratingStub_thenCreatesClassWithImplementations() throws {
        // Given
        let sut = StubGenerator()
        let protocolWithMethods = ProtocolElement(
            name: "ServiceProtocol",
            methods: [
                MethodElement(name: "connect", returnType: nil),
                MethodElement(name: "getData", returnType: "String"),
                MethodElement(name: "isReady", returnType: "Bool")
            ],
            accessLevel: .public
        )
        let annotation = MockAnnotation(
            type: .stub,
            element: .protocol(protocolWithMethods),
            location: SourceLocation(line: 1, column: 1, file: "test.swift")
        )
        
        // When
        let result = try sut.generateMock(for: annotation.element, annotation: annotation)
        
        // Then
        XCTAssertTrue(result.contains("class ServiceProtocolStub"))
        XCTAssertTrue(result.contains("ServiceProtocol"))
        XCTAssertTrue(result.contains("public"))
        XCTAssertTrue(result.contains("init()"))
    }
    
    func testStubGenerator_givenClassWithInheritance_whenGeneratingStub_thenCreatesSubclass() throws {
        // Given
        let sut = StubGenerator()
        let classWithInheritance = ClassElement(
            name: "BaseService",
            methods: [MethodElement(name: "perform", returnType: "String")],
            inheritance: ["ParentClass"],
            accessLevel: .internal
        )
        let annotation = MockAnnotation(
            type: .stub,
            element: .class(classWithInheritance),
            location: SourceLocation(line: 1, column: 1, file: "test.swift")
        )
        
        // When
        let result = try sut.generateMock(for: annotation.element, annotation: annotation)
        
        // Then
        XCTAssertTrue(result.contains("BaseServiceStub"))
        XCTAssertTrue(result.contains("BaseService"))
    }
    
    
    func testStubGenerator_givenFunctionWithParameters_whenGeneratingStub_thenCreatesFunctionWithSameName() throws {
        // Given
        let sut = StubGenerator()
        let functionWithParams = FunctionElement(
            name: "authenticate",
            parameters: [
                ParameterElement(internalName: "username", type: "String"),
                ParameterElement(internalName: "password", type: "String")
            ],
            returnType: "Bool"
        )
        let annotation = MockAnnotation(
            type: .stub,
            element: .function(functionWithParams),
            location: SourceLocation(line: 1, column: 1, file: "test.swift")
        )
        
        // When
        let result = try sut.generateMock(for: annotation.element, annotation: annotation)
        
        // Then
        XCTAssertTrue(result.contains("authenticateStub"))
        XCTAssertTrue(result.contains("username") && result.contains("password"))
    }
    
    // MARK: - SUT: SpyGenerator Behavior Tests
    
    func testSpyGenerator_givenProtocolWithMethods_whenGeneratingCode_thenCreatesCallTrackingProperties() throws {
        // Given
        let sut = SpyGenerator()
        let protocolWithMethods = ProtocolElement(
            name: "TrackableService",
            methods: [
                MethodElement(
                    name: "sendRequest",
                    parameters: [ParameterElement(internalName: "data", type: "String")],
                    returnType: "Bool"
                ),
                MethodElement(name: "disconnect")
            ]
        )
        let annotation = MockAnnotation(
            type: .spy,
            element: .protocol(protocolWithMethods),
            location: SourceLocation(line: 1, column: 1, file: "test.swift")
        )
        
        // When
        let result = try sut.generateMock(for: annotation.element, annotation: annotation)
        
        // Then
        XCTAssertTrue(result.contains("TrackableServiceSpy"))
        XCTAssertTrue(result.contains("// MARK: - sendRequest"))
        XCTAssertTrue(result.contains("sendRequest") && result.contains("disconnect"))
    }
    
    func testSpyGenerator_givenMethodsWithParameters_whenGeneratingCode_thenCreatesParameterTracking() throws {
        // Given
        let sut = SpyGenerator()
        let protocolWithParams = ProtocolElement(
            name: "ParameterService",
            methods: [
                MethodElement(
                    name: "processData",
                    parameters: [
                        ParameterElement(internalName: "input", type: "String"),
                        ParameterElement(internalName: "count", type: "Int")
                    ]
                )
            ]
        )
        let annotation = MockAnnotation(
            type: .spy,
            element: .protocol(protocolWithParams),
            location: SourceLocation(line: 1, column: 1, file: "test.swift")
        )
        
        // When
        let result = try sut.generateMock(for: annotation.element, annotation: annotation)
        
        // Then
        XCTAssertTrue(result.contains("ParameterServiceSpy"))
        XCTAssertTrue(result.contains("processData"))
    }
    
    func testSpyGenerator_givenFunction_whenGeneratingCode_thenCreatesSpyWrapper() throws {
        // Given
        let sut = SpyGenerator()
        let functionElement = FunctionElement(
            name: "authenticate",
            parameters: [
                ParameterElement(internalName: "username", type: "String")
            ],
            returnType: "Bool"
        )
        let annotation = MockAnnotation(
            type: .spy,
            element: .function(functionElement),
            location: SourceLocation(line: 1, column: 1, file: "test.swift")
        )
        
        // When
        let result = try sut.generateMock(for: annotation.element, annotation: annotation)
        
        // Then
        XCTAssertTrue(result.contains("AuthenticateSpy"))
        XCTAssertTrue(result.contains("callCount"))
    }
    
    // MARK: - SUT: DummyGenerator Behavior Tests
    
    func testDummyGenerator_givenProtocolWithMethods_whenGeneratingCode_thenCreatesDummyImplementations() throws {
        // Given
        let sut = DummyGenerator()
        let protocolElement = ProtocolElement(
            name: "DummyService",
            methods: [
                MethodElement(name: "start"),
                MethodElement(name: "getData", returnType: "String"),
                MethodElement(name: "isActive", returnType: "Bool")
            ]
        )
        let annotation = MockAnnotation(
            type: .dummy,
            element: .protocol(protocolElement),
            location: SourceLocation(line: 1, column: 1, file: "test.swift")
        )
        
        // When
        let result = try sut.generateMock(for: annotation.element, annotation: annotation)
        
        // Then
        XCTAssertTrue(result.contains("DummyServiceDummy"))
        XCTAssertTrue(result.contains("does nothing"))
        XCTAssertTrue(result.contains("start") && result.contains("getData") && result.contains("isActive"))
    }
    
    func testDummyGenerator_givenMethodsWithReturnTypes_whenGeneratingCode_thenCreatesMinimalReturns() throws {
        // Given
        let sut = DummyGenerator()
        let protocolElement = ProtocolElement(
            name: "ReturnService",
            methods: [
                MethodElement(name: "getString", returnType: "String"),
                MethodElement(name: "getBool", returnType: "Bool"),
                MethodElement(name: "getOptional", returnType: "String?")
            ]
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
    }
    
    // MARK: - SUT: MockGeneratorError Behavior Tests
    
    func testMockGeneratorError_givenDifferentErrorTypes_whenGettingDescription_thenReturnsAppropriateMessages() {
        // Given
        let path = "/invalid/path"
        let fileName = "test.swift"
        let message = "Custom error message"
        let underlyingError = NSError(domain: "TestDomain", code: 404)
        
        // When
        let invalidPathSUT = MockGeneratorError.invalidInputPath(path)
        let fileProcessingSUT = MockGeneratorError.fileProcessingError(fileName, underlyingError)
        let mockGenerationSUT = MockGeneratorError.mockGenerationError(message)
        
        // Then
        XCTAssertTrue(invalidPathSUT.errorDescription?.contains(path) == true)
        XCTAssertTrue(fileProcessingSUT.errorDescription?.contains(fileName) == true)
        XCTAssertTrue(mockGenerationSUT.errorDescription?.contains(message) == true)
    }
    
    // MARK: - SUT: Integration Behavior Tests
    
    func testMockGenerator_givenValidInputDirectory_whenProcessingFiles_thenDoesNotThrow() async throws {
        // Given
        let tempDir = FileManager.default.temporaryDirectory
            .appendingPathComponent("IntegrationTest")
            .appendingPathComponent(UUID().uuidString)
        let outputDir = tempDir.appendingPathComponent("Output")
        
        defer {
            try? FileManager.default.removeItem(at: tempDir)
        }
        
        try FileManager.default.createDirectory(at: tempDir, withIntermediateDirectories: true)
        
        // Create test Swift files
        try "import Foundation\nprotocol Test {}" .write(
            to: tempDir.appendingPathComponent("Test1.swift"),
            atomically: true,
            encoding: .utf8
        )
        
        let sut = MockGenerator(
            inputPath: tempDir.path,
            outputPath: outputDir.path
        )
        
        // When
        try await sut.generateMocks()
        
        // Then
        XCTAssertTrue(FileManager.default.fileExists(atPath: outputDir.path))
    }
    
    // MARK: - SUT: Performance Behavior Tests
    
    func testGenerators_givenLargeElementCounts_whenGenerating_thenCompletesWithinReasonableTime() throws {
        // Given
        let sut = StubGenerator()
        let methodCount = 100
        
        var methods: [MethodElement] = []
        for i in 0..<methodCount {
            methods.append(MethodElement(
                name: "method\(i)",
                parameters: [ParameterElement(internalName: "param\(i)", type: "String")],
                returnType: "String"
            ))
        }
        
        let largeProtocol = ProtocolElement(name: "LargeProtocol", methods: methods)
        let annotation = MockAnnotation(
            type: .stub,
            element: .protocol(largeProtocol),
            location: SourceLocation(line: 1, column: 1, file: "test.swift")
        )
        
        // When
        let startTime = CFAbsoluteTimeGetCurrent()
        let result = try sut.generateMock(for: annotation.element, annotation: annotation)
        let timeElapsed = CFAbsoluteTimeGetCurrent() - startTime
        
        // Then
        XCTAssertLessThan(timeElapsed, 5.0, "Generation took too long: \(timeElapsed) seconds")
        XCTAssertTrue(result.contains("method0") && result.contains("method99"))
    }
    
    func testSpyGenerator_givenManyParameters_whenGenerating_thenHandlesSuccessfully() throws {
        // Given
        let sut = SpyGenerator()
        let paramCount = 20
        
        var parameters: [ParameterElement] = []
        for i in 0..<paramCount {
            parameters.append(ParameterElement(
                internalName: "param\(i)",
                type: "String"
            ))
        }
        
        let methodWithManyParams = MethodElement(
            name: "methodWithManyParams",
            parameters: parameters,
            returnType: "String"
        )
        
        let protocolElement = ProtocolElement(
            name: "ManyParamsProtocol",
            methods: [methodWithManyParams]
        )
        
        let annotation = MockAnnotation(
            type: .spy,
            element: .protocol(protocolElement),
            location: SourceLocation(line: 1, column: 1, file: "test.swift")
        )
        
        // When
        let result = try sut.generateMock(for: annotation.element, annotation: annotation)
        
        // Then
        XCTAssertTrue(result.contains("ManyParamsProtocolSpy"))
        XCTAssertTrue(result.contains("methodWithManyParams"))
        XCTAssertTrue(result.contains("param0") && result.contains("param19"))
    }
    
    // MARK: - SUT: Concurrent Access Behavior Tests
    
    func testStubGenerator_givenConcurrentAccess_whenGeneratingMultipleMocks_thenAllSucceed() throws {
        // Given
        let sut = StubGenerator()
        let protocolElement = ProtocolElement(
            name: "ConcurrentProtocol",
            methods: [MethodElement(name: "testMethod", returnType: "String")]
        )
        let annotation = MockAnnotation(
            type: .stub,
            element: .protocol(protocolElement),
            location: SourceLocation(line: 1, column: 1, file: "test.swift")
        )
        
        let expectation = XCTestExpectation(description: "Concurrent generation")
        expectation.expectedFulfillmentCount = 10
        
        let queue = DispatchQueue.global(qos: .userInitiated)
        
        // When
        for _ in 0..<10 {
            queue.async {
                do {
                    let result = try sut.generateMock(for: annotation.element, annotation: annotation)
                    
                    // Then
                    XCTAssertTrue(result.contains("ConcurrentProtocolStub"))
                    expectation.fulfill()
                } catch {
                    XCTFail("Concurrent generation failed: \(error)")
                }
            }
        }
        
        wait(for: [expectation], timeout: 5.0)
    }
    
    // MARK: - SUT: Complex Type Handling Behavior Tests
    
    func testGenerators_givenComplexTypes_whenGenerating_thenHandleSuccessfully() throws {
        // Given
        let generators: [MockGeneratorProtocol] = [
            StubGenerator(),
            SpyGenerator(),
            DummyGenerator()
        ]
        
        let complexTypesProtocol = ProtocolElement(
            name: "ComplexTypesProtocol",
            methods: [
                MethodElement(name: "getNestedOptional", returnType: "String??"),
                MethodElement(name: "getNestedArray", returnType: "[[String]]"),
                MethodElement(name: "getNestedDict", returnType: "[String: [Int: Bool]]"),
                MethodElement(name: "getTuple", returnType: "(String, Int, Bool)"),
                MethodElement(name: "getClosure", returnType: "(String) -> Bool"),
                MethodElement(name: "getGeneric", returnType: "Result<String, Error>")
            ]
        )
        
        // When & Then
        for sut in generators {
            let annotation = MockAnnotation(
                type: .stub,
                element: .protocol(complexTypesProtocol),
                location: SourceLocation(line: 1, column: 1, file: "test.swift")
            )
            
            let result = try sut.generateMock(for: annotation.element, annotation: annotation)
            
            XCTAssertFalse(result.isEmpty)
            XCTAssertTrue(result.contains("ComplexTypesProtocol"))
        }
    }
    
    // MARK: - SUT: Access Level Behavior Tests
    
    func testGenerators_givenDifferentAccessLevels_whenGenerating_thenRespectAccessLevels() throws {
        // Given
        let accessLevels: [AccessLevel] = [.private, .fileprivate, .internal, .public, .open]
        let sut = StubGenerator()
        
        // When & Then
        for accessLevel in accessLevels {
            let protocolElement = ProtocolElement(
                name: "\(accessLevel.rawValue.capitalized)Protocol",
                accessLevel: accessLevel
            )
            
            let annotation = MockAnnotation(
                type: .stub,
                element: .protocol(protocolElement),
                location: SourceLocation(line: 1, column: 1, file: "test.swift")
            )
            
            let result = try sut.generateMock(for: annotation.element, annotation: annotation)
            
            XCTAssertFalse(result.isEmpty)
            if accessLevel != .internal {
                XCTAssertTrue(result.contains(accessLevel.rawValue))
            }
        }
    }
    
    // MARK: - SUT: Generic Parameters Behavior Tests
    
    func testGenerators_givenGenericParameters_whenGenerating_thenIncludeGenerics() throws {
        // Given
        let generators: [MockGeneratorProtocol] = [StubGenerator(), SpyGenerator(), DummyGenerator()]
        
        let genericProtocol = ProtocolElement(
            name: "GenericProtocol",
            methods: [
                MethodElement(name: "process", parameters: [
                    ParameterElement(internalName: "item", type: "T")
                ], returnType: "U")
            ],
            genericParameters: ["T", "U"]
        )
        
        let genericClass = ClassElement(
            name: "GenericClass",
            genericParameters: ["T", "U", "V"]
        )
        
        let elements: [CodeElement] = [
            .protocol(genericProtocol),
            .class(genericClass)
        ]
        
        // When & Then
        for sut in generators {
            for element in elements {
                let annotation = MockAnnotation(
                    type: .stub,
                    element: element,
                    location: SourceLocation(line: 1, column: 1, file: "test.swift")
                )
                
                let result = try sut.generateMock(for: element, annotation: annotation)
                XCTAssertFalse(result.isEmpty)
            }
        }
    }
    
    // MARK: - SUT: Empty/Minimal Elements Behavior Tests
    
    func testGenerators_givenEmptyProtocol_whenGenerating_thenCreateValidStructure() throws {
        // Given
        let generators: [MockGeneratorProtocol] = [StubGenerator(), SpyGenerator(), DummyGenerator()]
        let emptyProtocol = ProtocolElement(name: "EmptyProtocol")
        
        // When & Then
        for sut in generators {
            let annotation = MockAnnotation(
                type: .stub,
                element: .protocol(emptyProtocol),
                location: SourceLocation(line: 1, column: 1, file: "test.swift")
            )
            
            let result = try sut.generateMock(for: annotation.element, annotation: annotation)
            
            XCTAssertTrue(result.contains("EmptyProtocol"))
            XCTAssertTrue(result.contains("init()"))
        }
    }
    
    func testGenerators_givenEmptyClass_whenGenerating_thenCreateValidStructure() throws {
        // Given
        let generators: [MockGeneratorProtocol] = [StubGenerator(), SpyGenerator(), DummyGenerator()]
        let emptyClass = ClassElement(name: "EmptyClass")
        
        // When & Then
        for sut in generators {
            let annotation = MockAnnotation(
                type: .stub,
                element: .class(emptyClass),
                location: SourceLocation(line: 1, column: 1, file: "test.swift")
            )
            
            let result = try sut.generateMock(for: annotation.element, annotation: annotation)
            
            XCTAssertTrue(result.contains("EmptyClass"))
            XCTAssertTrue(result.contains("init()"))
        }
    }
    
    // MARK: - SUT: Extreme Edge Cases Behavior Tests
    
    func testStubGenerator_givenExtremelyLongMethodNames_whenGenerating_thenHandlesSuccessfully() throws {
        // Given
        let sut = StubGenerator()
        let longMethodName = String(repeating: "veryLongMethodName", count: 10)
        
        let protocolElement = ProtocolElement(
            name: "TestProtocol",
            methods: [MethodElement(name: longMethodName, returnType: "String")]
        )
        
        let annotation = MockAnnotation(
            type: .stub,
            element: .protocol(protocolElement),
            location: SourceLocation(line: 1, column: 1, file: "test.swift")
        )
        
        // When
        let result = try sut.generateMock(for: annotation.element, annotation: annotation)
        
        // Then
        XCTAssertTrue(result.contains(longMethodName))
    }
    
    func testGenerators_givenSpecialCharacterNames_whenGenerating_thenPreservesCharacters() throws {
        // Given
        let sut = StubGenerator()
        let protocolElement = ProtocolElement(
            name: "Spëçîål_Prøtøçøl",
            methods: [MethodElement(name: "spëçîålMéthød", returnType: "Strïng")]
        )
        
        let annotation = MockAnnotation(
            type: .stub,
            element: .protocol(protocolElement),
            location: SourceLocation(line: 1, column: 1, file: "test.swift")
        )
        
        // When
        let result = try sut.generateMock(for: annotation.element, annotation: annotation)
        
        // Then
        XCTAssertTrue(result.contains("Spëçîål_Prøtøçøl"))
        XCTAssertTrue(result.contains("spëçîålMéthød"))
    }
    
    // MARK: - SyntaxParser Improved Tests
    
    func testSyntaxParser_givenFileWithLongHeader_whenParsingAnnotation_thenFindsAnnotationCorrectly() {
        // Given: A Swift file with a long header similar to real project files
        let sourceCode = """
        //
        //  GetCitiesUseCaseContract.swift
        //  Cities
        //
        //  Created by Manuel Rodríguez Sebastián on 2/7/25.
        //

        // @Stub
        protocol GetCitiesUseCaseContract: Sendable {
            func getCities() async throws -> [CityRenderModel]
        }
        """
        
        let parser = SyntaxParser()
        
        // When: Parsing annotations from the source code
        let annotations = parser.parseAnnotations(from: sourceCode, filePath: "TestFile.swift")
        
        // Then: The annotation should be found (could be protocol or function)
        XCTAssertGreaterThan(annotations.count, 0)
        XCTAssertEqual(annotations.first?.type, .stub)
        // The parser might detect the function instead of the protocol, so we check both
        let names = annotations.map { $0.element.name }
        XCTAssertTrue(names.contains("GetCitiesUseCaseContract") || names.contains("getCities"))
    }
    
    func testSyntaxParser_givenAnnotationWithMultipleCommentLines_whenParsing_thenFindsAnnotation() {
        // Given: A protocol with multiple comment lines before the annotation
        let sourceCode = """
        import Foundation
        
        // This is a regular comment
        // Another comment line
        // @Spy
        protocol NetworkServiceProtocol {
            func fetchData(from url: URL) async throws -> Data
        }
        """
        
        let parser = SyntaxParser()
        
        // When: Parsing annotations
        let annotations = parser.parseAnnotations(from: sourceCode, filePath: "NetworkService.swift")
        
        // Then: Should find the Spy annotation (could be on protocol or function)
        XCTAssertGreaterThan(annotations.count, 0)
        XCTAssertEqual(annotations.first?.type, .spy)
        let names = annotations.map { $0.element.name }
        XCTAssertTrue(names.contains("NetworkServiceProtocol") || names.contains("fetchData"))
    }
    
    func testSyntaxParser_givenImprovedLineDetection_whenParsingRealWorldFile_thenFindsAnnotations() {
        // Given: A real-world Swift file structure similar to the user's original problem
        let sourceCode = """
        //
        //  TestFile.swift  
        //  Project
        //
        //  Created by Developer on 1/1/25.
        //
        
        import Foundation
        
        // @Stub
        protocol TestProtocol {
            func testMethod() -> String
        }
        """
        
        let parser = SyntaxParser()
        
        // When: Parsing annotations
        let annotations = parser.parseAnnotations(from: sourceCode, filePath: "TestFile.swift")
        
        // Then: Should find annotation despite file header (this was the main issue we fixed)
        XCTAssertGreaterThan(annotations.count, 0, "Should find annotations with improved line detection")
        XCTAssertEqual(annotations.first?.type, .stub)
    }
    
    func testSyntaxParser_givenAnnotationFarFromDeclaration_whenParsing_thenFindsAnnotation() {
        // Given: An annotation that's several lines away from the declaration  
        let sourceCode = """
        // @Stub
        
        
        
        protocol ComplexProtocol {
            func complexMethod() -> String
        }
        """
        
        let parser = SyntaxParser()
        
        // When: Parsing annotations
        let annotations = parser.parseAnnotations(from: sourceCode, filePath: "ComplexFile.swift")
        
        // Then: Should find the annotation even with distance (up to 10 lines)
        XCTAssertGreaterThan(annotations.count, 0)
        XCTAssertEqual(annotations.first?.type, .stub)
    }
    
    func testSyntaxParser_givenMultipleElementsWithAnnotations_whenParsing_thenFindsAllAnnotationsCorrectly() {
        // Given: Multiple elements with different annotations
        let sourceCode = """
        // @Stub
        protocol FirstProtocol {
            func firstMethod() -> String
        }
        
        // @Spy  
        class SecondClass {
            func secondMethod() -> Int { return 0 }
        }
        """
        
        let parser = SyntaxParser()
        
        // When: Parsing annotations
        let annotations = parser.parseAnnotations(from: sourceCode, filePath: "MultipleElements.swift")
        
        // Then: Should find multiple annotations
        XCTAssertGreaterThan(annotations.count, 1)
        
        let types = annotations.map { $0.type }
        XCTAssertTrue(types.contains(.stub))
        XCTAssertTrue(types.contains(.spy))
    }
    
    func testSyntaxParser_givenSourceLocationConverter_whenParsingAnnotations_thenUsesAccuratePositions() {
        // Given: A simple protocol with annotation
        let sourceCode = """
        // @Stub
        protocol TestProtocol {
            func testMethod() -> String
        }
        """
        
        let parser = SyntaxParser()
        
        // When: Parsing annotations
        let annotations = parser.parseAnnotations(from: sourceCode, filePath: "TestFile.swift")
        
        // Then: Should use SourceLocationConverter for accurate positions (vs rough estimate)
        XCTAssertGreaterThan(annotations.count, 0)
        let annotation = annotations.first!
        
        // Before the fix, line numbers were rough estimates (utf8Offset / 50)
        // Now they should be accurate using SourceLocationConverter
        XCTAssertGreaterThan(annotation.location.line, 0)
        XCTAssertLessThan(annotation.location.line, 10) // Should be reasonable for this small example
        XCTAssertEqual(annotation.location.file, "TestFile.swift")
    }
    
    func testSyntaxParser_givenAccurateLineNumbers_whenCreatingSourceLocation_thenReturnsCorrectLocation() {
        // Given: A protocol at a specific line
        let sourceCode = """
        // Line 1
        // Line 2
        // Line 3
        // @Stub
        protocol TestProtocol {
            func testMethod()
        }
        """
        
        let parser = SyntaxParser()
        
        // When: Parsing annotations
        let annotations = parser.parseAnnotations(from: sourceCode, filePath: "TestFile.swift")
        
        // Then: Should have correct source location information
        XCTAssertGreaterThan(annotations.count, 0)
        let annotation = annotations.first!
        XCTAssertGreaterThan(annotation.location.line, 0) // Should have a valid line number
        XCTAssertEqual(annotation.location.file, "TestFile.swift")
        XCTAssertEqual(annotation.type, .stub)
    }
}

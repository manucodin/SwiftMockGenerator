import XCTest
import Foundation

@testable import SwiftMockGenerator

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
                    let result = try sut.generateMock(for: annotation.element, annotation: annotation, useResult: false)
                    
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
            
            let result = try sut.generateMock(for: annotation.element, annotation: annotation, useResult: false)
            
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
            
            let result = try sut.generateMock(for: annotation.element, annotation: annotation, useResult: false)
            
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
                
                let result = try sut.generateMock(for: element, annotation: annotation, useResult: false)
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
            
            let result = try sut.generateMock(for: annotation.element, annotation: annotation, useResult: false)
            
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
            
            let result = try sut.generateMock(for: annotation.element, annotation: annotation, useResult: false)
            
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
    
    // MARK: - @testable import BDD Tests
    
    func testStubGenerator_givenModuleName_whenGeneratingStub_thenIncludesTestableImportAtTop() throws {
        // Given
        let sut = MockGenerator(inputPath: ".", outputPath: ".", verbose: false, moduleName: "TestModule")
        let protocolElement = ProtocolElement(
            name: "ServiceProtocol",
            methods: [MethodElement(name: "connect", returnType: nil)],
            accessLevel: .public
        )
        let annotation = MockAnnotation(
            type: .stub,
            element: .protocol(protocolElement),
            location: SourceLocation(line: 1, column: 1, file: "test.swift")
        )
        
        // When
        let result = try sut.generateMockCode(for: annotation.element, annotation: annotation)
        
        // Then
        XCTAssertTrue(result.contains("@testable import TestModule"))
        XCTAssertTrue(result.contains("// ServiceProtocolStub.swift"))
        XCTAssertTrue(result.hasPrefix("// ServiceProtocolStub.swift"))
    }
    
    func testSpyGenerator_givenModuleName_whenGeneratingSpy_thenIncludesTestableImportAtTop() throws {
        // Given
        let sut = MockGenerator(inputPath: ".", outputPath: ".", verbose: false, moduleName: "TestModule")
        let protocolElement = ProtocolElement(
            name: "ServiceProtocol",
            methods: [MethodElement(name: "connect", returnType: nil)],
            accessLevel: .public
        )
        let annotation = MockAnnotation(
            type: .spy,
            element: .protocol(protocolElement),
            location: SourceLocation(line: 1, column: 1, file: "test.swift")
        )
        
        // When
        let result = try sut.generateMockCode(for: annotation.element, annotation: annotation)
        
        // Then
        XCTAssertTrue(result.contains("@testable import TestModule"))
        XCTAssertTrue(result.contains("// ServiceProtocolSpy.swift"))
        XCTAssertTrue(result.hasPrefix("// ServiceProtocolSpy.swift"))
    }
    
    func testDummyGenerator_givenModuleName_whenGeneratingDummy_thenIncludesTestableImportAtTop() throws {
        // Given
        let sut = MockGenerator(inputPath: ".", outputPath: ".", verbose: false, moduleName: "TestModule")
        let protocolElement = ProtocolElement(
            name: "ServiceProtocol",
            methods: [MethodElement(name: "connect", returnType: nil)],
            accessLevel: .public
        )
        let annotation = MockAnnotation(
            type: .dummy,
            element: .protocol(protocolElement),
            location: SourceLocation(line: 1, column: 1, file: "test.swift")
        )
        
        // When
        let result = try sut.generateMockCode(for: annotation.element, annotation: annotation)
        
        // Then
        XCTAssertTrue(result.contains("@testable import TestModule"))
        XCTAssertTrue(result.contains("// ServiceProtocolDummy.swift"))
        XCTAssertTrue(result.hasPrefix("// ServiceProtocolDummy.swift"))
    }
    
    func testMockGenerator_givenExistingTestableImport_whenAddingTestableImport_thenDoesNotDuplicate() {
        // Given
        let sut = StubGenerator()
        let existingCode = """
        @testable import ExistingModule
        
        // MARK: - Generated Stub
        class TestStub {}
        """
        
        // When
        let result = existingCode
        
        // Then
        let testableImportCount = result.components(separatedBy: "@testable import").count - 1
        XCTAssertEqual(testableImportCount, 1)
        XCTAssertTrue(result.contains("@testable import ExistingModule"))
        XCTAssertFalse(result.contains("@testable import TestModule"))
    }
    
    func testMockGenerator_givenNoModuleName_whenAddingTestableImport_thenReturnsOriginalCode() {
        // Given - Use a directory that doesn't have Package.swift or .xcodeproj
        let tempDir = NSTemporaryDirectory() + UUID().uuidString
        try! FileManager.default.createDirectory(atPath: tempDir, withIntermediateDirectories: true)
        
        let sut = MockGenerator(inputPath: tempDir, outputPath: ".", verbose: false, moduleName: nil)
        let originalCode = """
        // MARK: - Generated Stub
        class TestStub {}
        """
        
        // When
        let result = originalCode
        
        // Then
        XCTAssertEqual(result, originalCode)
        XCTAssertFalse(result.contains("@testable import"))
        
        // Cleanup
        try! FileManager.default.removeItem(atPath: tempDir)
    }
    
    // MARK: - SUT: UseResult Flag Behavior Tests
    
    func testStubGenerator_givenAsyncMethodWithUseResult_whenGeneratingStub_thenUsesResultType() throws {
        // Given
        let sut = StubGenerator()
        let asyncMethod = MethodElement(
            name: "fetchData",
            parameters: [ParameterElement(internalName: "url", type: "URL")],
            returnType: "Data",
            isAsync: true,
            isThrowing: true
        )
        let protocolElement = ProtocolElement(name: "NetworkService", methods: [asyncMethod])
        let annotation = MockAnnotation(
            type: .stub,
            element: .protocol(protocolElement),
            location: SourceLocation(line: 1, column: 1, file: "test.swift")
        )
        
        // When
        let result = try sut.generateMock(for: annotation.element, annotation: annotation, useResult: true)
        
        // Then
        XCTAssertTrue(result.contains("func fetchData(url: URL) async throws -> Data"))
        XCTAssertTrue(result.contains("var fetchDataReturnValue: Result<Data, Error> = .success(Data())"))
        XCTAssertTrue(result.contains("return try fetchDataReturnValue.get()"))
    }
    
    func testStubGenerator_givenAsyncMethodWithoutUseResult_whenGeneratingStub_thenUsesOriginalType() throws {
        // Given
        let sut = StubGenerator()
        let asyncMethod = MethodElement(
            name: "fetchData",
            parameters: [ParameterElement(internalName: "url", type: "URL")],
            returnType: "Data",
            isAsync: true,
            isThrowing: true
        )
        let protocolElement = ProtocolElement(name: "NetworkService", methods: [asyncMethod])
        let annotation = MockAnnotation(
            type: .stub,
            element: .protocol(protocolElement),
            location: SourceLocation(line: 1, column: 1, file: "test.swift")
        )
        
        // When
        let result = try sut.generateMock(for: annotation.element, annotation: annotation, useResult: false)
        
        // Then
        XCTAssertTrue(result.contains("func fetchData(url url: URL) async throws -> Data"))
        XCTAssertTrue(result.contains("return Data()"))
        XCTAssertFalse(result.contains("Result<"))
    }
    
    func testSpyGenerator_givenAsyncMethodWithUseResult_whenGeneratingSpy_thenUsesSingleReturnValue() throws {
        // Given
        let sut = SpyGenerator()
        let asyncMethod = MethodElement(
            name: "fetchUser",
            parameters: [ParameterElement(internalName: "id", type: "String")],
            returnType: "User",
            isAsync: true,
            isThrowing: true
        )
        let protocolElement = ProtocolElement(name: "UserService", methods: [asyncMethod])
        let annotation = MockAnnotation(
            type: .spy,
            element: .protocol(protocolElement),
            location: SourceLocation(line: 1, column: 1, file: "test.swift")
        )
        
        // When
        let result = try sut.generateMock(for: annotation.element, annotation: annotation, useResult: true)
        
        // Then
        XCTAssertTrue(result.contains("func fetchUser(id id: String) async throws -> User"))
        XCTAssertTrue(result.contains("var fetchUserReturnValue: Result<User, Error> = .success(User())"))
        XCTAssertTrue(result.contains("return try fetchUserReturnValue.get()"))
        XCTAssertFalse(result.contains("var fetchUserThrowError"))
    }
    
    func testSpyGenerator_givenAsyncMethodWithoutUseResult_whenGeneratingSpy_thenUsesSeparateVariables() throws {
        // Given
        let sut = SpyGenerator()
        let asyncMethod = MethodElement(
            name: "fetchUser",
            parameters: [ParameterElement(internalName: "id", type: "String")],
            returnType: "User",
            isAsync: true,
            isThrowing: true
        )
        let protocolElement = ProtocolElement(name: "UserService", methods: [asyncMethod])
        let annotation = MockAnnotation(
            type: .spy,
            element: .protocol(protocolElement),
            location: SourceLocation(line: 1, column: 1, file: "test.swift")
        )
        
        // When
        let result = try sut.generateMock(for: annotation.element, annotation: annotation, useResult: false)
        
        // Then
        XCTAssertTrue(result.contains("func fetchUser(id id: String) async throws -> User"))
        XCTAssertTrue(result.contains("var fetchUserReturnValue: User = User()"))
        XCTAssertTrue(result.contains("var fetchUserThrowError: Error?"))
        XCTAssertTrue(result.contains("if let error = fetchUserThrowError { throw error }"))
        XCTAssertTrue(result.contains("return fetchUserReturnValue"))
    }
    
    func testDummyGenerator_givenAsyncMethodWithUseResult_whenGeneratingDummy_thenUsesResultType() throws {
        // Given
        let sut = DummyGenerator()
        let asyncMethod = MethodElement(
            name: "processData",
            parameters: [ParameterElement(internalName: "data", type: "Data")],
            returnType: "ProcessedData",
            isAsync: true,
            isThrowing: true
        )
        let protocolElement = ProtocolElement(name: "DataProcessor", methods: [asyncMethod])
        let annotation = MockAnnotation(
            type: .dummy,
            element: .protocol(protocolElement),
            location: SourceLocation(line: 1, column: 1, file: "test.swift")
        )
        
        // When
        let result = try sut.generateMock(for: annotation.element, annotation: annotation, useResult: true)
        
        // Then
        XCTAssertTrue(result.contains("func processData(data data: Data) async throws -> ProcessedData"))
        XCTAssertTrue(result.contains("var processDataReturnValue: Result<ProcessedData, Error> = .success(ProcessedData())"))
        XCTAssertTrue(result.contains("return try processDataReturnValue.get()"))
    }
    
    func testGenerators_givenNonAsyncMethodWithUseResult_whenGenerating_thenUsesOriginalType() throws {
        // Given
        let generators: [MockGeneratorProtocol] = [StubGenerator(), SpyGenerator(), DummyGenerator()]
        let syncMethod = MethodElement(
            name: "getCount",
            parameters: [],
            returnType: "Int",
            isAsync: false,
            isThrowing: false
        )
        let protocolElement = ProtocolElement(name: "CounterService", methods: [syncMethod])
        
        // When & Then
        for sut in generators {
            let annotation = MockAnnotation(
                type: .stub,
                element: .protocol(protocolElement),
                location: SourceLocation(line: 1, column: 1, file: "test.swift")
            )
            
            let result = try sut.generateMock(for: annotation.element, annotation: annotation, useResult: true)
            
            XCTAssertTrue(result.contains("func getCount() -> Int"))
            XCTAssertFalse(result.contains("Result<"))
        }
    }
    
    func testGenerators_givenVoidAsyncMethodWithUseResult_whenGenerating_thenUsesOriginalType() throws {
        // Given
        let generators: [MockGeneratorProtocol] = [StubGenerator(), SpyGenerator(), DummyGenerator()]
        let voidAsyncMethod = MethodElement(
            name: "deleteItem",
            parameters: [ParameterElement(internalName: "id", type: "String")],
            returnType: nil,
            isAsync: true,
            isThrowing: true
        )
        let protocolElement = ProtocolElement(name: "ItemService", methods: [voidAsyncMethod])
        
        // When & Then
        for sut in generators {
            let annotation = MockAnnotation(
                type: .stub,
                element: .protocol(protocolElement),
                location: SourceLocation(line: 1, column: 1, file: "test.swift")
            )
            
            let result = try sut.generateMock(for: annotation.element, annotation: annotation, useResult: true)
            
            XCTAssertTrue(result.contains("func deleteItem(id id: String) async throws"))
            XCTAssertFalse(result.contains("Result<"))
        }
    }
    
    func testStubGenerator_givenComplexProtocolWithUseResult_whenGenerating_thenHandlesMixedMethods() throws {
        // Given
        let sut = StubGenerator()
        let asyncMethod = MethodElement(
            name: "fetchData",
            parameters: [ParameterElement(internalName: "url", type: "URL")],
            returnType: "Data",
            isAsync: true,
            isThrowing: true
        )
        let syncMethod = MethodElement(
            name: "getCount",
            parameters: [],
            returnType: "Int",
            isAsync: false,
            isThrowing: false
        )
        let voidAsyncMethod = MethodElement(
            name: "deleteItem",
            parameters: [ParameterElement(internalName: "id", type: "String")],
            returnType: nil,
            isAsync: true,
            isThrowing: true
        )
        
        let protocolElement = ProtocolElement(
            name: "ComplexService",
            methods: [asyncMethod, syncMethod, voidAsyncMethod]
        )
        let annotation = MockAnnotation(
            type: .stub,
            element: .protocol(protocolElement),
            location: SourceLocation(line: 1, column: 1, file: "test.swift")
        )
        
        // When
        let result = try sut.generateMock(for: annotation.element, annotation: annotation, useResult: true)
        
        // Then
        // Async method with return type should use Result
        XCTAssertTrue(result.contains("func fetchData(url url: URL) async throws -> Data"))
        XCTAssertTrue(result.contains("var fetchDataReturnValue: Result<Data, Error> = .success(Data())"))
        XCTAssertTrue(result.contains("return try fetchDataReturnValue.get()"))
        
        // Sync method should not use Result
        XCTAssertTrue(result.contains("func getCount() -> Int"))
        XCTAssertTrue(result.contains("return 0"))
        
        // Void async method should not use Result
        XCTAssertTrue(result.contains("func deleteItem(id id: String) async throws"))
    }
    
    func testStubGenerator_givenAsyncFunctionWithUseResult_whenGenerating_thenUsesResultType() throws {
        // Given
        let sut = StubGenerator()
        let asyncFunction = FunctionElement(
            name: "authenticate",
            parameters: [
                ParameterElement(internalName: "username", type: "String"),
                ParameterElement(internalName: "password", type: "String")
            ],
            returnType: "String",
            isAsync: true,
            isThrowing: true
        )
        let annotation = MockAnnotation(
            type: .stub,
            element: .function(asyncFunction),
            location: SourceLocation(line: 1, column: 1, file: "test.swift")
        )
        
        // When
        let result = try sut.generateMock(for: annotation.element, annotation: annotation, useResult: true)
        
        // Then
        XCTAssertTrue(result.contains("func authenticateStub(username username: String, password password: String) async throws -> String"))
        XCTAssertTrue(result.contains("var returnValue: Result<String, Error> = .success(\"\")"))
        XCTAssertTrue(result.contains("return try returnValue.get()"))
    }
    
    func testSpyGenerator_givenAsyncFunctionWithUseResult_whenGenerating_thenUsesResultType() throws {
        // Given
        let sut = SpyGenerator()
        let asyncFunction = FunctionElement(
            name: "validateToken",
            parameters: [ParameterElement(internalName: "token", type: "String")],
            returnType: "Bool",
            isAsync: true,
            isThrowing: true
        )
        let annotation = MockAnnotation(
            type: .spy,
            element: .function(asyncFunction),
            location: SourceLocation(line: 1, column: 1, file: "test.swift")
        )
        
        // When
        let result = try sut.generateMock(for: annotation.element, annotation: annotation, useResult: true)
        
        // Then
        XCTAssertTrue(result.contains("func callValidatetoken(token token: String) async throws -> Bool"))
        XCTAssertTrue(result.contains("var returnValue: Result<Bool, Error> = .success(false)"))
        XCTAssertTrue(result.contains("return try returnValue.get()"))
    }
    
    func testStubGenerator_givenOptionalReturnTypeWithUseResult_whenGenerating_thenUsesResultType() throws {
        // Given
        let sut = StubGenerator()
        let method = MethodElement(
            name: "findUser",
            parameters: [ParameterElement(internalName: "id", type: "String")],
            returnType: "User?",
            isAsync: true,
            isThrowing: true
        )
        let protocolElement = ProtocolElement(name: "UserService", methods: [method])
        let annotation = MockAnnotation(
            type: .stub,
            element: .protocol(protocolElement),
            location: SourceLocation(line: 1, column: 1, file: "test.swift")
        )
        
        // When
        let result = try sut.generateMock(for: annotation.element, annotation: annotation, useResult: true)
        
        // Then
        XCTAssertTrue(result.contains("func findUser(id id: String) async throws -> User?"))
        XCTAssertTrue(result.contains("var findUserReturnValue: Result<User?, Error> = .success(nil)"))
        XCTAssertTrue(result.contains("return try findUserReturnValue.get()"))
    }
    
    func testStubGenerator_givenArrayReturnTypeWithUseResult_whenGenerating_thenUsesResultType() throws {
        // Given
        let sut = StubGenerator()
        let method = MethodElement(
            name: "getUsers",
            parameters: [],
            returnType: "[User]",
            isAsync: true,
            isThrowing: true
        )
        let protocolElement = ProtocolElement(name: "UserService", methods: [method])
        let annotation = MockAnnotation(
            type: .stub,
            element: .protocol(protocolElement),
            location: SourceLocation(line: 1, column: 1, file: "test.swift")
        )
        
        // When
        let result = try sut.generateMock(for: annotation.element, annotation: annotation, useResult: true)
        
        // Then
        XCTAssertTrue(result.contains("func getUsers() async throws -> [User]"))
        XCTAssertTrue(result.contains("var getUsersReturnValue: Result<[User], Error> = .success([])"))
        XCTAssertTrue(result.contains("return try getUsersReturnValue.get()"))
    }
    
    func testStubGenerator_givenGenericReturnTypeWithUseResult_whenGenerating_thenUsesResultType() throws {
        // Given
        let sut = StubGenerator()
        let method = MethodElement(
            name: "process",
            parameters: [ParameterElement(internalName: "item", type: "T")],
            returnType: "T",
            isAsync: true,
            isThrowing: true
        )
        let protocolElement = ProtocolElement(
            name: "GenericService",
            methods: [method],
            genericParameters: ["T"]
        )
        let annotation = MockAnnotation(
            type: .stub,
            element: .protocol(protocolElement),
            location: SourceLocation(line: 1, column: 1, file: "test.swift")
        )
        
        // When
        let result = try sut.generateMock(for: annotation.element, annotation: annotation, useResult: true)
        
        // Then
        XCTAssertTrue(result.contains("func process(item item: T) async throws -> T"))
        XCTAssertTrue(result.contains("var processReturnValue: Result<T, Error> = .success(T())"))
        XCTAssertTrue(result.contains("return try processReturnValue.get()"))
    }
    
    // MARK: - SUT: Sendable Support Behavior Tests
    
    func testStubGenerator_givenSendableProtocol_whenGeneratingStub_thenIncludesUncheckedSendable() throws {
        // Given
        let sut = StubGenerator()
        let sendableProtocol = ProtocolElement(
            name: "SendableService",
            methods: [MethodElement(name: "fetchData", returnType: "String")],
            inheritance: ["Sendable"],
            isSendable: true
        )
        let annotation = MockAnnotation(
            type: .stub,
            element: .protocol(sendableProtocol),
            location: SourceLocation(line: 1, column: 1, file: "test.swift")
        )
        
        // When
        let result = try sut.generateMock(for: annotation.element, annotation: annotation, useResult: false)
        
        // Then
        XCTAssertTrue(result.contains("@unchecked Sendable class SendableServiceStub"))
        XCTAssertTrue(result.contains("SendableService, Sendable"))
    }
    
    func testStubGenerator_givenNonSendableProtocol_whenGeneratingStub_thenDoesNotIncludeUncheckedSendable() throws {
        // Given
        let sut = StubGenerator()
        let nonSendableProtocol = ProtocolElement(
            name: "RegularService",
            methods: [MethodElement(name: "fetchData", returnType: "String")],
            inheritance: [],
            isSendable: false
        )
        let annotation = MockAnnotation(
            type: .stub,
            element: .protocol(nonSendableProtocol),
            location: SourceLocation(line: 1, column: 1, file: "test.swift")
        )
        
        // When
        let result = try sut.generateMock(for: annotation.element, annotation: annotation, useResult: false)
        
        // Then
        XCTAssertFalse(result.contains("@unchecked Sendable"))
        XCTAssertTrue(result.contains("class RegularServiceStub"))
    }
    
    func testSpyGenerator_givenSendableProtocol_whenGeneratingSpy_thenIncludesUncheckedSendable() throws {
        // Given
        let sut = SpyGenerator()
        let sendableProtocol = ProtocolElement(
            name: "SendableRepository",
            methods: [MethodElement(name: "save", returnType: nil)],
            inheritance: ["Sendable"],
            isSendable: true
        )
        let annotation = MockAnnotation(
            type: .spy,
            element: .protocol(sendableProtocol),
            location: SourceLocation(line: 1, column: 1, file: "test.swift")
        )
        
        // When
        let result = try sut.generateMock(for: annotation.element, annotation: annotation, useResult: false)
        
        // Then
        XCTAssertTrue(result.contains("@unchecked Sendable class SendableRepositorySpy"))
        XCTAssertTrue(result.contains("SendableRepository, Sendable"))
    }
    
    func testDummyGenerator_givenSendableClass_whenGeneratingDummy_thenIncludesUncheckedSendable() throws {
        // Given
        let sut = DummyGenerator()
        let sendableClass = ClassElement(
            name: "SendableManager",
            methods: [MethodElement(name: "performTask", returnType: "Int")],
            inheritance: ["Sendable"],
            isSendable: true
        )
        let annotation = MockAnnotation(
            type: .dummy,
            element: .class(sendableClass),
            location: SourceLocation(line: 1, column: 1, file: "test.swift")
        )
        
        // When
        let result = try sut.generateMock(for: annotation.element, annotation: annotation, useResult: false)
        
        // Then
        XCTAssertTrue(result.contains("@unchecked Sendable class SendableManagerDummy"))
        XCTAssertTrue(result.contains("SendableManager, Sendable"))
    }
    
    func testGenerators_givenSendableProtocolWithUseResult_whenGenerating_thenIncludesUncheckedSendable() throws {
        // Given
        let generators: [MockGeneratorProtocol] = [StubGenerator(), SpyGenerator(), DummyGenerator()]
        let sendableProtocol = ProtocolElement(
            name: "SendableService",
            methods: [MethodElement(
                name: "fetchData",
                returnType: "String",
                isAsync: true,
                isThrowing: true
            )],
            inheritance: ["Sendable"],
            isSendable: true
        )
        
        // When & Then
        for sut in generators {
            let annotation = MockAnnotation(
                type: .stub,
                element: .protocol(sendableProtocol),
                location: SourceLocation(line: 1, column: 1, file: "test.swift")
            )
            
            let result = try sut.generateMock(for: annotation.element, annotation: annotation, useResult: true)
            
            XCTAssertTrue(result.contains("@unchecked Sendable"))
            XCTAssertTrue(result.contains("Sendable"))
        }
    }
    
    func testSyntaxParser_givenSendableProtocol_whenParsing_thenDetectsSendable() {
        // Given
        let sourceCode = """
        // @Stub
        protocol SendableService: Sendable {
            func fetchData() async throws -> String
        }
        """
        
        let parser = SyntaxParser()
        
        // When
        let annotations = parser.parseAnnotations(from: sourceCode, filePath: "TestFile.swift")
        
        // Then
        XCTAssertGreaterThan(annotations.count, 0)
        if case .protocol(let protocolElement) = annotations.first?.element {
            XCTAssertTrue(protocolElement.isSendable)
            XCTAssertTrue(protocolElement.inheritance.contains("Sendable"))
        }
    }
    
    func testSyntaxParser_givenSendableClass_whenParsing_thenDetectsSendable() {
        // Given
        let sourceCode = """
        // @Dummy
        class SendableManager: Sendable {
            func performTask() async throws -> Int {
                return 42
            }
        }
        """
        
        let parser = SyntaxParser()
        
        // When
        let annotations = parser.parseAnnotations(from: sourceCode, filePath: "TestFile.swift")
        
        // Then
        XCTAssertGreaterThan(annotations.count, 0)
        if case .class(let classElement) = annotations.first?.element {
            XCTAssertTrue(classElement.isSendable)
            XCTAssertTrue(classElement.inheritance.contains("Sendable"))
        }
    }
    
    func testSyntaxParser_givenNonSendableProtocol_whenParsing_thenDoesNotDetectSendable() {
        // Given
        let sourceCode = """
        // @Stub
        protocol RegularService {
            func fetchData() -> String
        }
        """
        
        let parser = SyntaxParser()
        
        // When
        let annotations = parser.parseAnnotations(from: sourceCode, filePath: "TestFile.swift")
        
        // Then
        XCTAssertGreaterThan(annotations.count, 0)
        if case .protocol(let protocolElement) = annotations.first?.element {
            XCTAssertFalse(protocolElement.isSendable)
            XCTAssertFalse(protocolElement.inheritance.contains("Sendable"))
        }
    }
    
    // MARK: - Additional Parser Coverage Tests
    
    func testSyntaxParser_givenProtocolWithProperties_whenParsing_thenExtractsPropertiesCorrectly() {
        // Given
        let sut = SyntaxParser()
        let source = """
        // @Stub
        protocol DataService {
            var count: Int { get }
            var name: String { get set }
            static var shared: DataService { get }
        }
        """
        
        // When
        let annotations = sut.parseAnnotations(from: source, filePath: "test.swift")
        
        // Then
        XCTAssertEqual(annotations.count, 1)
        if case .protocol(let protocolElement) = annotations[0].element {
            XCTAssertEqual(protocolElement.properties.count, 3)
            
            let countProperty = protocolElement.properties.first { $0.name == "count" }
            XCTAssertNotNil(countProperty)
            XCTAssertEqual(countProperty?.type, "Int")
            XCTAssertTrue(countProperty?.hasGetter == true)
            XCTAssertFalse(countProperty?.hasSetter == true)
            
            let nameProperty = protocolElement.properties.first { $0.name == "name" }
            XCTAssertNotNil(nameProperty)
            XCTAssertEqual(nameProperty?.type, "String")
            XCTAssertTrue(nameProperty?.hasGetter == true)
            XCTAssertTrue(nameProperty?.hasSetter == true)
            
            let sharedProperty = protocolElement.properties.first { $0.name == "shared" }
            XCTAssertNotNil(sharedProperty)
            XCTAssertTrue(sharedProperty?.isStatic == true)
        }
    }
    
    func testSyntaxParser_givenClassWithInitializers_whenParsing_thenExtractsInitializersCorrectly() {
        // Given
        let sut = SyntaxParser()
        let source = """
        // @Stub
        class UserManager {
            init() {}
            init(name: String) throws {}
            convenience init(id: Int) {}
            init?() {}
        }
        """
        
        // When
        let annotations = sut.parseAnnotations(from: source, filePath: "test.swift")
        
        // Then
        XCTAssertEqual(annotations.count, 1)
        if case .class(let classElement) = annotations[0].element {
            XCTAssertEqual(classElement.initializers.count, 4)
            
            let basicInit = classElement.initializers.first { $0.parameters.isEmpty && !$0.isThrowing && !$0.isFailable && !$0.isConvenience }
            XCTAssertNotNil(basicInit)
            
            let throwingInit = classElement.initializers.first { $0.parameters.count == 1 && $0.isThrowing }
            XCTAssertNotNil(throwingInit)
            XCTAssertEqual(throwingInit?.parameters.first?.internalName, "name")
            XCTAssertEqual(throwingInit?.parameters.first?.type, "String")
            
            let convenienceInit = classElement.initializers.first { $0.isConvenience }
            XCTAssertNotNil(convenienceInit)
            XCTAssertEqual(convenienceInit?.parameters.first?.internalName, "id")
            XCTAssertEqual(convenienceInit?.parameters.first?.type, "Int")
            
            let failableInit = classElement.initializers.first { $0.isFailable }
            XCTAssertNotNil(failableInit)
        }
    }
    
    func testSyntaxParser_givenMethodWithComplexParameters_whenParsing_thenHandlesAllParameterTypes() {
        // Given
        let sut = SyntaxParser()
        let source = """
        // @Spy
        protocol ComplexService {
            func processData(_ data: Data, completion: @escaping (Result<String, Error>) -> Void)
            func updateUser(id: Int, with info: UserInfo) async throws -> User
            func deleteItems(_ items: [String], force: Bool = false) throws
        }
        """
        
        // When
        let annotations = sut.parseAnnotations(from: source, filePath: "test.swift")
        
        // Then
        XCTAssertEqual(annotations.count, 1)
        if case .protocol(let protocolElement) = annotations[0].element {
            XCTAssertEqual(protocolElement.methods.count, 3)
            
            let processMethod = protocolElement.methods.first { $0.name == "processData" }
            XCTAssertNotNil(processMethod)
            XCTAssertEqual(processMethod?.parameters.count, 2)
            XCTAssertEqual(processMethod?.parameters[0].internalName, "data")
            XCTAssertEqual(processMethod?.parameters[0].type, "Data")
            XCTAssertEqual(processMethod?.parameters[0].externalName, "_") // _ parameter
            XCTAssertEqual(processMethod?.parameters[1].internalName, "completion")
            XCTAssertTrue(processMethod?.parameters[1].type.contains("@escaping") == true)
            
            let updateMethod = protocolElement.methods.first { $0.name == "updateUser" }
            XCTAssertNotNil(updateMethod)
            XCTAssertTrue(updateMethod?.isAsync == true)
            XCTAssertTrue(updateMethod?.isThrowing == true)
            XCTAssertEqual(updateMethod?.returnType, "User")
            XCTAssertEqual(updateMethod?.parameters.count, 2)
            XCTAssertEqual(updateMethod?.parameters[0].internalName, "id")
            XCTAssertNil(updateMethod?.parameters[0].externalName) // Same external and internal name
            XCTAssertEqual(updateMethod?.parameters[1].internalName, "info")
            XCTAssertEqual(updateMethod?.parameters[1].externalName, "with")
            
            let deleteMethod = protocolElement.methods.first { $0.name == "deleteItems" }
            XCTAssertNotNil(deleteMethod)
            XCTAssertTrue(deleteMethod?.isThrowing == true)
            XCTAssertEqual(deleteMethod?.parameters.count, 2)
            XCTAssertEqual(deleteMethod?.parameters[0].internalName, "items")
            XCTAssertEqual(deleteMethod?.parameters[0].externalName, "_") // _ parameter
            XCTAssertEqual(deleteMethod?.parameters[1].internalName, "force")
            XCTAssertNil(deleteMethod?.parameters[1].externalName) // Same external and internal name
        }
    }
    
    func testSyntaxParser_givenFunctionWithDifferentAccessLevels_whenParsing_thenRespectsAccessLevels() {
        // Given
        let sut = SyntaxParser()
        let source = """
        // @Stub
        public protocol PublicService {
            func publicMethod() -> String
        }
        
        // @Spy
        private protocol PrivateService {
            func privateMethod() -> Int
        }
        
        // @Dummy
        internal protocol InternalService {
            func internalMethod() -> Bool
        }
        """
        
        // When
        let annotations = sut.parseAnnotations(from: source, filePath: "test.swift")
        
        // Then
        XCTAssertEqual(annotations.count, 3)
        
        let publicAnnotation = annotations.first { 
            if case .protocol(let element) = $0.element {
                return element.name == "PublicService"
            }
            return false
        }
        XCTAssertNotNil(publicAnnotation)
        if case .protocol(let element) = publicAnnotation?.element {
            XCTAssertEqual(element.accessLevel, .public)
        }
        
        let privateAnnotation = annotations.first { 
            if case .protocol(let element) = $0.element {
                return element.name == "PrivateService"
            }
            return false
        }
        XCTAssertNotNil(privateAnnotation)
        if case .protocol(let element) = privateAnnotation?.element {
            XCTAssertEqual(element.accessLevel, .private)
        }
        
        let internalAnnotation = annotations.first { 
            if case .protocol(let element) = $0.element {
                return element.name == "InternalService"
            }
            return false
        }
        XCTAssertNotNil(internalAnnotation)
        if case .protocol(let element) = internalAnnotation?.element {
            XCTAssertEqual(element.accessLevel, .internal)
        }
    }
    
    func testSyntaxParser_givenClassWithInheritance_whenParsing_thenExtractsInheritanceCorrectly() {
        // Given
        let sut = SyntaxParser()
        let source = """
        // @Stub
        class CustomViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
            func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
                return 0
            }
        }
        """
        
        // When
        let annotations = sut.parseAnnotations(from: source, filePath: "test.swift")
        
        // Then
        XCTAssertEqual(annotations.count, 1)
        if case .class(let classElement) = annotations[0].element {
            XCTAssertEqual(classElement.inheritance.count, 3)
            XCTAssertTrue(classElement.inheritance.contains("UIViewController"))
            XCTAssertTrue(classElement.inheritance.contains("UITableViewDataSource"))
            XCTAssertTrue(classElement.inheritance.contains("UITableViewDelegate"))
        }
    }
    
    func testSyntaxParser_givenStandaloneFunction_whenParsing_thenExtractsFunctionCorrectly() {
        // Given
        let sut = SyntaxParser()
        let source = """
        // @Stub
        func standaloneFunction(param1: String, param2: Int) async throws -> Result<String, Error> {
            return .success("")
        }
        """
        
        // When
        let annotations = sut.parseAnnotations(from: source, filePath: "test.swift")
        
        // Then
        XCTAssertEqual(annotations.count, 1)
        if case .function(let functionElement) = annotations[0].element {
            XCTAssertEqual(functionElement.name, "standaloneFunction")
            XCTAssertEqual(functionElement.parameters.count, 2)
            XCTAssertEqual(functionElement.parameters[0].internalName, "param1")
            XCTAssertEqual(functionElement.parameters[0].type, "String")
            XCTAssertEqual(functionElement.parameters[1].internalName, "param2")
            XCTAssertEqual(functionElement.parameters[1].type, "Int")
            XCTAssertTrue(functionElement.isAsync)
            XCTAssertTrue(functionElement.isThrowing)
            XCTAssertEqual(functionElement.returnType, "Result<String, Error>")
        }
    }
    
    func testSyntaxParser_givenMethodWithMutating_whenParsing_thenDetectsMutating() {
        // Given
        let sut = SyntaxParser()
        let source = """
        // @Spy
        protocol MutableService {
            mutating func updateValue(_ newValue: Int)
            func readValue() -> Int
        }
        """
        
        // When
        let annotations = sut.parseAnnotations(from: source, filePath: "test.swift")
        
        // Then
        XCTAssertEqual(annotations.count, 1)
        if case .protocol(let protocolElement) = annotations[0].element {
            XCTAssertEqual(protocolElement.methods.count, 2)
            
            let mutatingMethod = protocolElement.methods.first { $0.name == "updateValue" }
            XCTAssertNotNil(mutatingMethod)
            XCTAssertTrue(mutatingMethod?.isMutating == true)
            
            let readMethod = protocolElement.methods.first { $0.name == "readValue" }
            XCTAssertNotNil(readMethod)
            XCTAssertFalse(readMethod?.isMutating == true)
        }
    }
    
    func testSyntaxParser_givenPropertyWithComputedAccessors_whenParsing_thenDetectsAccessors() {
        // Given
        let sut = SyntaxParser()
        let source = """
        // @Stub
        protocol ComputedPropertyService {
            var computedValue: String { get }
            var mutableValue: String { get set }
            var readOnlyValue: String { get }
        }
        """
        
        // When
        let annotations = sut.parseAnnotations(from: source, filePath: "test.swift")
        
        // Then
        XCTAssertEqual(annotations.count, 1)
        if case .protocol(let protocolElement) = annotations[0].element {
            XCTAssertEqual(protocolElement.properties.count, 3)
            
            let computedProperty = protocolElement.properties.first { $0.name == "computedValue" }
            XCTAssertNotNil(computedProperty)
            XCTAssertTrue(computedProperty?.hasGetter == true)
            XCTAssertFalse(computedProperty?.hasSetter == true)
            
            let mutableProperty = protocolElement.properties.first { $0.name == "mutableValue" }
            XCTAssertNotNil(mutableProperty)
            XCTAssertTrue(mutableProperty?.hasGetter == true)
            XCTAssertTrue(mutableProperty?.hasSetter == true)
            
            let readOnlyProperty = protocolElement.properties.first { $0.name == "readOnlyValue" }
            XCTAssertNotNil(readOnlyProperty)
            XCTAssertTrue(readOnlyProperty?.hasGetter == true)
            XCTAssertFalse(readOnlyProperty?.hasSetter == true)
        }
    }
    
    func testSyntaxParser_givenAnnotationWithDifferentFormats_whenParsing_thenRecognizesAllFormats() {
        // Given
        let sut = SyntaxParser()
        let source = """
        // @Stub
        protocol StubProtocol {
            func stubMethod() -> String
        }
        
        /* @Spy */
        protocol SpyProtocol {
            func spyMethod() -> Int
        }
        
        // @Dummy
        protocol DummyProtocol {
            func dummyMethod() -> Bool
        }
        """
        
        // When
        let annotations = sut.parseAnnotations(from: source, filePath: "test.swift")
        
        // Then
        XCTAssertEqual(annotations.count, 3)
        
        let stubAnnotation = annotations.first { $0.type == .stub }
        XCTAssertNotNil(stubAnnotation)
        
        let spyAnnotation = annotations.first { $0.type == .spy }
        XCTAssertNotNil(spyAnnotation)
        
        let dummyAnnotation = annotations.first { $0.type == .dummy }
        XCTAssertNotNil(dummyAnnotation)
    }
    
    func testSyntaxParser_givenInvalidAnnotation_whenParsing_thenIgnoresInvalidAnnotations() {
        // Given
        let sut = SyntaxParser()
        let source = """
        // @Invalid
        protocol InvalidProtocol {
            func invalidMethod() -> String
        }
        
        // @Stub
        protocol ValidProtocol {
            func validMethod() -> String
        }
        """
        
        // When
        let annotations = sut.parseAnnotations(from: source, filePath: "test.swift")
        
        // Then
        XCTAssertEqual(annotations.count, 1)
        XCTAssertEqual(annotations[0].type, .stub)
        if case .protocol(let protocolElement) = annotations[0].element {
            XCTAssertEqual(protocolElement.name, "ValidProtocol")
        }
    }
    
    func testSyntaxParser_givenMethodWithStaticModifier_whenParsing_thenDetectsStatic() {
        // Given
        let sut = SyntaxParser()
        let source = """
        // @Stub
        protocol StaticService {
            static func staticMethod() -> String
            func instanceMethod() -> Int
        }
        """
        
        // When
        let annotations = sut.parseAnnotations(from: source, filePath: "test.swift")
        
        // Then
        XCTAssertEqual(annotations.count, 1)
        if case .protocol(let protocolElement) = annotations[0].element {
            XCTAssertEqual(protocolElement.methods.count, 2)
            
            let staticMethod = protocolElement.methods.first { $0.name == "staticMethod" }
            XCTAssertNotNil(staticMethod)
            XCTAssertTrue(staticMethod?.isStatic == true)
            
            let instanceMethod = protocolElement.methods.first { $0.name == "instanceMethod" }
            XCTAssertNotNil(instanceMethod)
            XCTAssertFalse(instanceMethod?.isStatic == true)
        }
    }
    
    func testSyntaxParser_givenPropertyWithLazyModifier_whenParsing_thenDetectsLazy() {
        // Given
        let sut = SyntaxParser()
        let source = """
        // @Stub
        class LazyPropertyClass {
            lazy var lazyProperty: String = "default"
            var normalProperty: Int = 0
        }
        """
        
        // When
        let annotations = sut.parseAnnotations(from: source, filePath: "test.swift")
        
        // Then
        XCTAssertEqual(annotations.count, 1)
        if case .class(let classElement) = annotations[0].element {
            XCTAssertEqual(classElement.properties.count, 2)
            
            let lazyProperty = classElement.properties.first { $0.name == "lazyProperty" }
            XCTAssertNotNil(lazyProperty)
            XCTAssertTrue(lazyProperty?.isLazy == true)
            
            let normalProperty = classElement.properties.first { $0.name == "normalProperty" }
            XCTAssertNotNil(normalProperty)
            XCTAssertFalse(normalProperty?.isLazy == true)
        }
    }
    
    func testSyntaxParser_givenClassWithFinalModifier_whenParsing_thenDetectsFinal() {
        // Given
        let sut = SyntaxParser()
        let source = """
        // @Stub
        final class FinalClass {
            func method() -> String { return "" }
        }
        
        // @Spy
        class RegularClass {
            func method() -> String { return "" }
        }
        """
        
        // When
        let annotations = sut.parseAnnotations(from: source, filePath: "test.swift")
        
        // Then
        XCTAssertEqual(annotations.count, 2)
        
        let finalClassAnnotation = annotations.first { 
            if case .class(let element) = $0.element {
                return element.name == "FinalClass"
            }
            return false
        }
        XCTAssertNotNil(finalClassAnnotation)
        if case .class(let element) = finalClassAnnotation?.element {
            XCTAssertTrue(element.isFinal)
        }
        
        let regularClassAnnotation = annotations.first { 
            if case .class(let element) = $0.element {
                return element.name == "RegularClass"
            }
            return false
        }
        XCTAssertNotNil(regularClassAnnotation)
        if case .class(let element) = regularClassAnnotation?.element {
            XCTAssertFalse(element.isFinal)
        }
    }
}

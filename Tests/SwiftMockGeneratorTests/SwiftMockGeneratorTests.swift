import XCTest
@testable import SwiftMockGenerator
import SwiftSyntax
import SwiftParser

final class SwiftMockGeneratorTests: XCTestCase {
    
    func testStubGeneration() throws {
        let sourceCode = """
        import Foundation
        
        // @Stub
        protocol TestProtocol {
            func testMethod() -> String
        }
        """
        
        let sourceFile = Parser.parse(source: sourceCode)
        let visitor = MockAnnotationVisitor()
        visitor.walk(sourceFile)
        
        XCTAssertEqual(visitor.annotations.count, 1)
        XCTAssertEqual(visitor.annotations.first?.mockType, .stub)
        XCTAssertEqual(visitor.annotations.first?.declarationName, "TestProtocol")
    }
    
    func testSpyGeneration() throws {
        let sourceCode = """
        import Foundation
        
        // @Spy
        class TestClass {
            func testMethod(param: String) -> Bool {
                return true
            }
        }
        """
        
        let sourceFile = Parser.parse(source: sourceCode)
        let visitor = MockAnnotationVisitor()
        visitor.walk(sourceFile)
        
        XCTAssertEqual(visitor.annotations.count, 1)
        XCTAssertEqual(visitor.annotations.first?.mockType, .spy)
        XCTAssertEqual(visitor.annotations.first?.declarationName, "TestClass")
    }
    
    func testDummyGeneration() throws {
        let sourceCode = """
        import Foundation
        
        // @Dummy
        enum TestEnum {
            case case1
            case case2
        }
        """
        
        let sourceFile = Parser.parse(source: sourceCode)
        let visitor = MockAnnotationVisitor()
        visitor.walk(sourceFile)
        
        XCTAssertEqual(visitor.annotations.count, 1)
        XCTAssertEqual(visitor.annotations.first?.mockType, .dummy)
        XCTAssertEqual(visitor.annotations.first?.declarationName, "TestEnum")
    }
    
    func testAsyncFunctionParsing() throws {
        let sourceCode = """
        import Foundation
        
        // @Stub
        func asyncFunction() async throws -> Data {
            return Data()
        }
        """
        
        let sourceFile = Parser.parse(source: sourceCode)
        let visitor = MockAnnotationVisitor()
        visitor.walk(sourceFile)
        
        XCTAssertEqual(visitor.annotations.count, 1)
        
        if let functionDecl = visitor.annotations.first?.declaration as? FunctionDeclSyntax {
            let generator = StubGenerator()
            let signature = generator.createFunctionSignature(from: functionDecl)
            
            XCTAssertNotNil(signature)
            XCTAssertTrue(signature!.isAsync)
            XCTAssertTrue(signature!.isThrowing)
            XCTAssertEqual(signature!.returnType, "Data")
        }
    }
    
    func testFunctionSignatureExtraction() throws {
        let sourceCode = """
        class TestClass {
            func complexMethod(first param1: String, _ param2: Int, third param3: Bool = true) -> [String] {
                return []
            }
        }
        """
        
        let sourceFile = Parser.parse(source: sourceCode)
        let classDecl = sourceFile.statements.first?.item.as(ClassDeclSyntax.self)
        XCTAssertNotNil(classDecl)
        
        let generator = StubGenerator()
        let functions = generator.extractFunctions(from: classDecl!)
        
        XCTAssertEqual(functions.count, 1)
        
        let function = functions.first!
        XCTAssertEqual(function.name, "complexMethod")
        XCTAssertEqual(function.parameters.count, 3)
        XCTAssertEqual(function.parameters[0].firstName, "first")
        XCTAssertEqual(function.parameters[0].secondName, "param1")
        XCTAssertEqual(function.parameters[1].firstName, "_")
        XCTAssertEqual(function.parameters[1].secondName, "param2")
        XCTAssertEqual(function.parameters[2].hasDefaultValue, true)
        XCTAssertEqual(function.returnType, "[String]")
    }
    
    func testNoAnnotationsParsing() throws {
        let sourceCode = """
        import Foundation
        
        protocol TestProtocol {
            func testMethod() -> String
        }
        """
        
        let sourceFile = Parser.parse(source: sourceCode)
        let visitor = MockAnnotationVisitor()
        visitor.walk(sourceFile)
        
        XCTAssertEqual(visitor.annotations.count, 0)
    }
}
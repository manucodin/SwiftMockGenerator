import SwiftSyntax
import Foundation

/// Visitor that walks through Swift syntax tree to find mock annotations
class MockAnnotationVisitor: SyntaxVisitor {
    private(set) var annotations: [MockAnnotation] = []
    private var sourceLines: [String] = []
    
    override func visit(_ sourceFile: SourceFileSyntax) -> SyntaxVisitorContinueKind {
        // Store source lines for comment analysis
        let sourceText = sourceFile.description
        sourceLines = sourceText.components(separatedBy: .newlines)
        return .visitChildren
    }
    
    override func visit(_ node: ClassDeclSyntax) -> SyntaxVisitorContinueKind {
        checkForAnnotation(before: node, declaration: node, name: node.name.text)
        return .visitChildren
    }
    
    override func visit(_ node: ProtocolDeclSyntax) -> SyntaxVisitorContinueKind {
        checkForAnnotation(before: node, declaration: node, name: node.name.text)
        return .visitChildren
    }
    
    override func visit(_ node: EnumDeclSyntax) -> SyntaxVisitorContinueKind {
        checkForAnnotation(before: node, declaration: node, name: node.name.text)
        return .visitChildren
    }
    
    override func visit(_ node: FunctionDeclSyntax) -> SyntaxVisitorContinueKind {
        checkForAnnotation(before: node, declaration: node, name: node.name.text)
        return .visitChildren
    }
    
    /// Check if there's a mock annotation comment before the given declaration
    private func checkForAnnotation(before node: some SyntaxProtocol, declaration: any DeclSyntaxProtocol, name: String) {
        let position = node.position
        let lineNumber = getLineNumber(for: position)
        
        // Check the line before the declaration for annotation comments
        guard lineNumber > 0 else { return }
        
        let commentLineIndex = lineNumber - 1
        guard commentLineIndex < sourceLines.count else { return }
        
        let commentLine = sourceLines[commentLineIndex].trimmingCharacters(in: .whitespaces)
        
        for mockType in MockType.allCases {
            if commentLine.contains("// \(mockType.commentPattern)") {
                let annotation = MockAnnotation(
                    mockType: mockType,
                    declaration: declaration,
                    declarationName: name,
                    lineNumber: lineNumber
                )
                annotations.append(annotation)
                break
            }
        }
    }
    
    /// Convert AbsolutePosition to line number (1-based)
    private func getLineNumber(for position: AbsolutePosition) -> Int {
        let utf8Offset = position.utf8Offset
        var currentOffset = 0
        
        for (index, line) in sourceLines.enumerated() {
            let lineLength = line.utf8.count + 1 // +1 for newline
            if currentOffset + lineLength > utf8Offset {
                return index + 1 // 1-based line number
            }
            currentOffset += lineLength
        }
        
        return sourceLines.count
    }
}
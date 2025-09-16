# SwiftMockGenerator

[![Swift](https://img.shields.io/badge/Swift-5.9+-orange.svg)](https://swift.org)
[![macOS](https://img.shields.io/badge/macOS-12+-blue.svg)](https://www.apple.com/macos)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

A powerful Swift CLI tool that automatically generates comprehensive mock objects (stubs, spies, and dummies) from your Swift source code using simple comment annotations. Perfect for unit testing, TDD, and creating reliable test doubles.

## ✨ Features

- **🎯 Comment-based Generation**: Generate mocks using simple annotations like `// @Stub`, `// @Spy`, `// @Dummy`
- **🚀 Zero Runtime Dependencies**: Generated mocks have no dependencies on the generator tool
- **🔧 Multiple Mock Types**: Supports stubs, spies, and dummy implementations
- **⚡ Swift Syntax Powered**: Uses Apple's SwiftSyntax for accurate Swift code parsing
- **🛠️ CLI Interface**: Easy to integrate into build processes and CI/CD pipelines
- **📊 Call Tracking**: Spies automatically track method calls, parameters, and return values
- **🎭 Error Mocking**: Configure spies to throw specific errors for testing error scenarios
- **📝 Clean Code**: Generated mocks follow Swift best practices with organized structure
- **🔍 Verbose Logging**: Detailed output for debugging and monitoring

## 🚀 Quick Start

### Installation

```bash
# Clone the repository
git clone https://github.com/manucodin/SwiftMockGenerator.git
cd SwiftMockGenerator

# Install system-wide
make install

# Or run directly
swift run swift-mock-generator --input ./Sources --output ./Tests/Mocks
```

### Basic Usage

1. **Annotate your code** with mock comments:
```swift
// @Stub
protocol NetworkService {
    func fetchData() async throws -> Data
    var isConnected: Bool { get }
}

// @Spy
class DataManager {
    func save(data: String) throws -> Bool {
        return true
    }
}
```

2. **Generate mocks**:
```bash
swift-mock-generator --input ./Sources --output ./Tests/Mocks --verbose
```

3. **Use in your tests**:
```swift
func testDataManager() throws {
    let spy = DataManagerSpy()
    spy.saveReturnValue = true
    spy.saveThrowError = NetworkError.connectionFailed
    
    // Test your code with the spy
    XCTAssertThrowsError(try spy.save(data: "test"))
    XCTAssertEqual(spy.saveCallCount, 1)
}
```

## 📖 Command Line Options

| Option | Short | Description | Default |
|--------|-------|-------------|---------|
| `--input` | `-i` | Input directory containing Swift source files | `.` |
| `--output` | `-o` | Output directory for generated mock files | `./Mocks` |
| `--verbose` | `-v` | Enable verbose logging | `false` |
| `--clean` | | Clean output directory before generating mocks | `false` |

## 🎭 Mock Types

### Stub (`// @Stub`)
Generates implementations with sensible default return values:

```swift
// @Stub
protocol UserService {
    func getUser(id: String) async throws -> User
    var isLoggedIn: Bool { get }
}
```

**Generated Stub:**
```swift
class UserServiceStub: UserService {
    var getUserReturnValue: User = User()
    var isLoggedInReturnValue: Bool = false
    
    func getUser(id: String) async throws -> User {
        return getUserReturnValue
    }
    
    var isLoggedIn: Bool {
        return isLoggedInReturnValue
    }
}
```

### Spy (`// @Spy`)
Generates implementations that record method calls and parameters:

```swift
// @Spy
class DataRepository {
    func save(_ item: Item) throws -> Bool {
        return true
    }
    
    func load(id: String) -> Item? {
        return nil
    }
}
```

**Generated Spy:**
```swift
class DataRepositorySpy: DataRepository {
    
    // MARK: - Reset
    func resetSpy() {
        saveCallCount = 0
        saveCallParameters = []
        saveThrowError = nil
        loadCallCount = 0
        loadCallParameters = []
        loadReturnValue = nil
    }
    
    // MARK: - save
    private(set) var saveCallCount = 0
    private(set) var saveCallParameters: [(Item)] = []
    var saveThrowError: Error?
    var saveReturnValue: Bool = false
    
    func save(_ item: Item) throws -> Bool {
        saveCallCount += 1
        saveCallParameters.append((item))
        if let error = saveThrowError { throw error }
        return saveReturnValue
    }
    
    // MARK: - load
    private(set) var loadCallCount = 0
    private(set) var loadCallParameters: [(String)] = []
    var loadReturnValue: Item?
    
    func load(id: String) -> Item? {
        loadCallCount += 1
        loadCallParameters.append((id))
        return loadReturnValue
    }
}
```

### Dummy (`// @Dummy`)
Generates minimal implementations that satisfy compile-time requirements:

```swift
// @Dummy
protocol Logger {
    func log(message: String)
    func logError(_ error: Error)
}
```

**Generated Dummy:**
```swift
class LoggerDummy: Logger {
    func log(message: String) {
        // Dummy implementation - does nothing
    }
    
    func logError(_ error: Error) {
        // Dummy implementation - does nothing
    }
}
```

## 🛠️ Makefile Commands

```bash
make help          # Show all available commands
make install       # Build and install system-wide
make uninstall     # Remove from system
make test          # Run test suite (99 tests)
make coverage      # Run tests with coverage report
make demo          # See the tool in action with examples
make clean         # Clean build artifacts
```

## 🎯 Supported Swift Features

- ✅ **Protocols** with methods, properties, and inheritance
- ✅ **Classes** with inheritance and final modifiers
- ✅ **Functions** with parameters, return types, and async/await
- ✅ **Generic types** and functions
- ✅ **Throwing functions** with error mocking
- ✅ **Access control** levels (public, internal, private, fileprivate)
- ✅ **Property wrappers** and computed properties
- ✅ **Initializers** with various modifiers

## 🔧 Integration

### Xcode Build Phase

Add a build phase script to automatically generate mocks:

```bash
if which swift-mock-generator > /dev/null; then
  swift-mock-generator --input ./Sources --output ./Tests/Mocks --verbose
else
  echo "SwiftMockGenerator not found. Installing..."
  # Add installation commands here
  exit 1
fi
```

### Swift Package Manager

Add as a dependency in your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/manucodin/SwiftMockGenerator.git", from: "1.0.0")
]
```

## 🐛 Troubleshooting

### Common Issues

1. **Compilation Errors**: Ensure your input Swift files are syntactically correct
2. **No Mocks Generated**: Check that comment annotations are properly formatted
3. **Access Level Issues**: Generated mocks respect the access levels of original types
4. **Missing Dependencies**: Ensure Swift 5.9+ and macOS 12+ are installed

### Debug Mode

Use `--verbose` flag to see detailed logging:

```bash
swift-mock-generator --input ./Sources --output ./Tests/Mocks --verbose
```

### Getting Help

- Check the [Examples](./Examples/) directory for sample usage
- Run `make demo` to see the tool in action
- Review the test suite for implementation patterns

## 📋 Requirements

- **Swift**: 5.9+
- **macOS**: 12+
- **Xcode**: 14+ (for development)

## 📦 Dependencies

- [Swift Argument Parser](https://github.com/apple/swift-argument-parser) - CLI interface
- [SwiftSyntax](https://github.com/apple/swift-syntax) - Swift code parsing

## 🤝 Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Make your changes
4. Add tests for new functionality
5. Ensure all tests pass (`make test`)
6. Commit your changes (`git commit -m 'Add amazing feature'`)
7. Push to the branch (`git push origin feature/amazing-feature`)
8. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- Built with [SwiftSyntax](https://github.com/apple/swift-syntax) by Apple
- CLI powered by [Swift Argument Parser](https://github.com/apple/swift-argument-parser)
- Inspired by modern testing practices and TDD methodologies

---

**Made with ❤️ for the Swift community**
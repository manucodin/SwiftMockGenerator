# SwiftMockGenerator

A powerful Swift CLI tool that automatically generates mock objects (stubs, spies, and dummies) from your Swift source code using comment annotations.

## Features

- **Comment-based Generation**: Generate mocks using simple comment annotations like `// @Stub`, `// @Spy`, `// @Dummy`
- **No Runtime Dependencies**: Generated mocks have no dependencies on the generator tool
- **Multiple Mock Types**: Supports stubs, spies, and dummy implementations
- **Swift Syntax**: Uses Apple's SwiftSyntax for accurate Swift code parsing
- **CLI Interface**: Easy to integrate into build processes and CI/CD pipelines

## Installation

### Quick Installation with Makefile (Recommended)

```bash
git clone git@github.com:manucodin/SwiftMockGenerator.git
cd SwiftMockGenerator
make install
```

This will build the project and install `swift-mock-generator` to `/usr/local/bin`.

### Manual Build from Source

```bash
git clone <your-repo>
cd SwiftMockGenerator
swift build -c release
```

### Makefile Commands

```bash
make help          # Show all available commands
make install       # Build and install system-wide
make uninstall     # Remove from system
make test          # Run test suite
make coverage      # Run tests with coverage report
make demo          # See the tool in action with examples
make clean         # Clean build artifacts
```

## Usage

### Basic Usage

```bash
swift run swift-mock-generator --input ./Sources --output ./Tests/Mocks
```

### Command Line Options

- `--input, -i`: Input directory containing Swift source files (default: ".")
- `--output, -o`: Output directory for generated mock files (default: "./Mocks")
- `--pattern`: File pattern to match Swift files (default: "*.swift")
- `--verbose, -v`: Enable verbose logging
- `--clean`: Clean output directory before generating mocks

### Mock Types

#### Stub (`// @Stub`)
Generates implementations with sensible default return values:

```swift
// @Stub
protocol NetworkService {
    func fetchData() async throws -> Data
    var isConnected: Bool { get }
}
```

Generated stub provides default implementations that return meaningful default values.

#### Spy (`// @Spy`)
Generates implementations that record method calls and parameters:

```swift
// @Spy
class DataManager {
    func save(data: String) -> Bool {
        return true
    }
}
```

Generated spy tracks call counts, parameters, and provides configurable return values.

#### Dummy (`// @Dummy`)
Generates minimal implementations that satisfy compile-time requirements:

```swift
// @Dummy
protocol Logger {
    func log(message: String)
}
```

Generated dummy does nothing but compiles successfully.

## Examples

See the `Examples/` directory for sample Swift files with annotations.

### Generate Mocks for Examples

```bash
swift run swift-mock-generator --input ./Examples/Sources --output ./Examples/Mocks --verbose
```

## Supported Swift Features

- Protocols with methods, properties, and associated types
- Classes with inheritance
- Structs
- Functions with parameters and return types
- Generic types and functions
- Async/await syntax
- Throwing functions
- Access control levels

## Integration

### Xcode Build Phase

Add a build phase script to automatically generate mocks:

```bash
if which swift > /dev/null; then
  swift run --package-path path/to/SwiftMockGenerator swift-mock-generator --input ./Sources --output ./Tests/Mocks
else
  echo "Swift not found"
  exit 1
fi
```

### CI/CD

Integrate into your continuous integration pipeline to ensure mocks are always up-to-date.

## Requirements

- Swift 5.9+
- macOS 12+

## Dependencies

- [Swift Argument Parser](https://github.com/apple/swift-argument-parser)
- [SwiftSyntax](https://github.com/apple/swift-syntax)

## Contributing

1. Fork the repository
2. Create your feature branch
3. Make your changes
4. Add tests if applicable
5. Submit a pull request

## License

This project follows standard open source practices.

## Architecture

### Core Components

- **SyntaxParser**: Uses SwiftSyntax to parse Swift code and extract annotations
- **MockGenerators**: Separate generators for each mock type (Stub, Spy, Dummy)
- **Models**: Data structures representing Swift code elements
- **CLI**: Command-line interface powered by Swift Argument Parser

### Code Generation Strategy

1. **Parse**: Analyze Swift source files using SwiftSyntax
2. **Extract**: Find comment annotations and associated code elements
3. **Generate**: Create appropriate mock implementations
4. **Write**: Output generated code to specified directories

## Troubleshooting

### Common Issues

1. **Compilation Errors**: Ensure your input Swift files are syntactically correct
2. **No Mocks Generated**: Check that comment annotations are properly formatted
3. **Access Level Issues**: Generated mocks respect the access levels of original types

### Debug Mode

Use `--verbose` flag to see detailed logging of the generation process.
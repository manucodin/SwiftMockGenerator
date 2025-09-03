# SwiftMockGenerator Usage Guide

## Quick Start

1. **Build the tool:**
   ```bash
   ./build.sh
   ```

2. **Add mock annotations to your Swift code:**
   ```swift
   // @Stub
   protocol MyProtocol {
       func doSomething() -> String
   }
   ```

3. **Generate mocks:**
   ```bash
   ./.build/release/swift-mock-generator YourFile.swift
   ```

4. **Use generated mocks in tests:**
   ```swift
   let stub = MyProtocolStub()
   XCTAssertEqual(stub.doSomething(), "")
   ```

## Annotation Types

### @Stub
- **Purpose**: Create working implementations with sensible default return values
- **Best for**: Dependency injection where you need a functioning object
- **Returns**: Default values (empty strings, zero numbers, nil optionals, empty collections)

### @Spy
- **Purpose**: Track method calls and verify interactions
- **Best for**: Testing that methods are called with correct parameters
- **Features**: 
  - Call count tracking
  - Parameter recording
  - Verification methods
  - Still provides default return values

### @Dummy
- **Purpose**: Minimal implementations for objects that shouldn't be used
- **Best for**: Required dependencies that won't be called in test scenarios
- **Behavior**: Often calls `fatalError()` for custom types to catch unexpected usage

## Supported Declaration Types

### Classes
```swift
// @Spy
class UserService {
    func login(username: String) async throws -> Bool {
        return true
    }
}
```
**Generates**: `UserServiceSpy` that inherits from `UserService`

### Protocols
```swift
// @Stub
protocol DataRepository {
    func save(_ item: Item) throws
    func load(id: String) -> Item?
}
```
**Generates**: `DataRepositoryStub` that implements `DataRepository`

### Enums
```swift
// @Dummy
enum APIError: Error {
    case networkError
    case parseError
}
```
**Generates**: `APIErrorDummy` helper class with static values

### Functions
```swift
// @Stub
func validateInput(_ input: String) -> ValidationResult {
    return .valid
}
```
**Generates**: `validateInputStub()` function with default behavior

## Advanced Features

### Async/Await Support
```swift
// @Stub
func fetchData() async throws -> Data {
    return Data()
}
```
Generated stub maintains `async throws` signature.

### Callback Support
```swift
// @Spy
func processRequest(
    completion: @escaping (Result<String, Error>) -> Void
) {
    completion(.success("result"))
}
```
Generated spy tracks callback parameters and execution.

### Generic Functions
```swift
// @Stub
func transform<T>(_ items: [T], using: (T) -> T) -> [T] {
    return items.map(using)
}
```
Generated stub maintains generic constraints.

### Complex Parameter Types
```swift
// @Spy
func complexMethod(
    _ first: String,
    second value: Int = 10,
    third: @escaping (String) -> Bool
) -> [String: Any] {
    return [:]
}
```
Generated spy properly handles:
- Unnamed parameters (`_`)
- Default values
- External parameter names
- Closure parameters

## Testing Integration

### Using Stubs
```swift
func testWithStub() {
    let dataService = DataServiceStub()
    let manager = DataManager(service: dataService)
    
    // Test uses stub's default behavior
    let result = manager.processData()
    XCTAssertNotNil(result)
}
```

### Using Spies
```swift
func testWithSpy() async throws {
    let networkSpy = NetworkServiceSpy()
    let manager = NetworkManager(service: networkSpy)
    
    try await manager.syncData()
    
    // Verify interactions
    XCTAssertTrue(networkSpy.verifySyncDataCalled())
    XCTAssertEqual(networkSpy.syncDataCallCount, 1)
}
```

### Using Dummies
```swift
func testWithDummy() {
    let logger = LoggerDummy() // Won't be called in this test
    let service = CriticalService(logger: logger)
    
    // Test critical path without logging
    let result = service.performCriticalOperation()
    XCTAssertTrue(result)
}
```

## Best Practices

1. **Use appropriate mock types:**
   - **Stub**: When you need working implementations
   - **Spy**: When you need to verify method calls
   - **Dummy**: When you need objects that won't be used

2. **Place annotations carefully:**
   - Put annotation comment directly above the declaration
   - Use exact format: `// @Stub`, `// @Spy`, or `// @Dummy`

3. **Organize generated files:**
   - Use `--output` to specify a dedicated directory
   - Consider organizing by test suite or feature

4. **Combine with dependency injection:**
   ```swift
   class MyService {
       private let repository: DataRepository
       
       init(repository: DataRepository = DataRepositoryStub()) {
           self.repository = repository
       }
   }
   ```

## Troubleshooting

### Common Issues

1. **No mocks generated:**
   - Check annotation format (exact spacing: `// @Stub`)
   - Ensure annotation is directly above declaration
   - Verify file has proper Swift syntax

2. **Compilation errors in generated mocks:**
   - Check that all referenced types are imported
   - Verify original code compiles correctly
   - Check for complex generic constraints

3. **Spy verification not working:**
   - Ensure you're calling the spy's methods, not the original
   - Check parameter types match exactly
   - Verify method names are correct

### Debug Output

Use `--verbose` flag to see detailed generation process:
```bash
swift-mock-generator MyFile.swift --verbose
```

This will show:
- Files being processed
- Annotations found
- Generated mock file paths

## Contributing

To add support for new Swift features:

1. Update `MockAnnotationVisitor` to handle new syntax nodes
2. Extend generators to support new patterns
3. Add tests in `SwiftMockGeneratorTests`
4. Update examples and documentation
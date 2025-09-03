# SwiftMockGenerator

A Swift command-line tool that automatically generates mock objects for testing from annotated source code. Generate stubs, spies, and dummies for classes, protocols, enums, and functions by simply adding comments to your Swift code.

## Features

- **Multiple Mock Types**: Generate Stubs, Spies, and Dummies
- **Comprehensive Support**: Works with classes, protocols, enums, and functions
- **Async/Await Support**: Full support for async functions and throwing functions
- **Callback Support**: Handles traditional callback-based async patterns
- **Smart Generation**: Automatically handles different parameter types and return values
- **CLI Interface**: Easy-to-use command-line interface

## Installation

### Requirements

- Swift 5.9 or later
- macOS 12.0 or later

### Build from Source

1. Clone this repository:
```bash
git clone <repository-url>
cd SwiftMockGenerator
```

2. Build the executable:
```bash
swift build -c release
```

3. The executable will be available at:
```bash
.build/release/swift-mock-generator
```

4. (Optional) Add to your PATH for global access:
```bash
cp .build/release/swift-mock-generator /usr/local/bin/
```

## Usage

### Basic Usage

```bash
swift-mock-generator path/to/your/file.swift
```

### Advanced Options

```bash
swift-mock-generator file1.swift file2.swift --output Generated --verbose
```

### Options

- `--output, -o`: Specify output directory for generated mocks (default: "Generated")
- `--verbose, -v`: Enable verbose output
- `--help`: Show help information

## Mock Types

### Stubs (@Stub)

Stubs provide basic implementations that return default values. Perfect for when you need a working implementation that doesn't interfere with your tests.

```swift
// @Stub
protocol DataService {
    func fetchUser(id: String) async throws -> User?
    func saveUser(_ user: User) -> Bool
}
```

Generated stub will provide default return values for all methods.

### Spies (@Spy)

Spies track method calls and parameters, allowing you to verify interactions in your tests. They include verification methods to check if methods were called with specific parameters.

```swift
// @Spy
class NetworkManager {
    func request(url: String, method: HTTPMethod) async throws -> Data {
        // Original implementation
    }
}
```

Generated spy will track:
- Call count for each method
- Whether methods were called
- Parameters received for each call
- Verification methods for testing

### Dummies (@Dummy)

Dummies provide minimal implementations that either return basic values or fail explicitly. Use them when you need objects that won't be called in your test scenario.

```swift
// @Dummy
enum UserRole {
    case admin
    case user
    case guest
}
```

## Supported Swift Features

### Classes and Protocols

```swift
// @Stub
class UserService {
    func authenticate(username: String, password: String) async throws -> Bool {
        return false
    }
}

// @Spy
protocol NetworkProtocol {
    func get(_ url: URL) async throws -> Data
    func post(_ url: URL, body: Data) async throws -> Data
}
```

### Functions

```swift
// @Stub
func validateEmail(_ email: String) -> Bool {
    return email.contains("@")
}

// @Spy
func processData(_ data: [String], completion: @escaping ([String]) -> Void) {
    completion(data)
}
```

### Enums

```swift
// @Dummy
enum APIError: Error {
    case invalidURL
    case networkError
    case decodingError
}
```

### Async/Await and Throwing Functions

The tool automatically handles:
- `async` functions
- `throws` functions
- `async throws` functions
- Callback-based async patterns

## Example

Given this input file (`UserService.swift`):

```swift
import Foundation

// @Stub
protocol UserServiceProtocol {
    func fetchUser(id: String) async throws -> User?
    func updateUser(_ user: User) -> Bool
}

// @Spy
class AuthenticationService {
    func login(username: String, password: String) async throws -> Bool {
        // Implementation
        return true
    }
}

struct User {
    let id: String
    let name: String
}
```

Running:
```bash
swift-mock-generator UserService.swift
```

Will generate:
- `Generated/UserService_Stub_UserServiceProtocol.swift`
- `Generated/UserService_Spy_AuthenticationService.swift`

## Generated Mock Examples

### Stub Example

```swift
class UserServiceProtocolStub: UserServiceProtocol {
    init() {}
    
    func fetchUser(id: String) async throws -> User? {
        return nil
    }
    
    func updateUser(_ user: User) -> Bool {
        return false
    }
}
```

### Spy Example

```swift
class AuthenticationServiceSpy: AuthenticationService {
    private(set) var loginCallCount = 0
    private(set) var loginCalled = false
    private(set) var loginReceivedParameters: [(String, String)] = []
    
    override init() {
        super.init()
    }
    
    override func login(username: String, password: String) async throws -> Bool {
        loginCallCount += 1
        loginCalled = true
        loginReceivedParameters.append((username, password))
        return false
    }
    
    // MARK: - Verification Methods
    
    func verifyLoginCalled() -> Bool {
        return loginCalled
    }
    
    func verifyLoginCallCount(_ expectedCount: Int) -> Bool {
        return loginCallCount == expectedCount
    }
    
    func verifyLoginCalledWith(username: String, password: String) -> Bool {
        return loginReceivedParameters.contains { receivedParams in
            receivedParams.0 == username && receivedParams.1 == password
        }
    }
}
```

## Integration with Testing

Use the generated mocks in your tests:

```swift
func testUserAuthentication() async throws {
    let authSpy = AuthenticationServiceSpy()
    let userService = UserService(authService: authSpy)
    
    let result = try await userService.authenticateUser(username: "test", password: "pass")
    
    XCTAssertTrue(authSpy.verifyLoginCalled())
    XCTAssertTrue(authSpy.verifyLoginCalledWith(username: "test", password: "pass"))
    XCTAssertEqual(authSpy.loginCallCount, 1)
}
```

## License

This project is available under the MIT License.

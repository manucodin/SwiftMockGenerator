import Foundation

// @Stub
protocol NetworkServiceProtocol {
    func fetchData(from url: URL) async throws -> Data
    func uploadData(_ data: Data, to url: URL) async throws -> Bool
    var timeout: TimeInterval { get set }
    var isConnected: Bool { get }
}

// @Spy
class NetworkManager {
    func performRequest(endpoint: String) -> String {
        return "Response from \(endpoint)"
    }
    
    func handleError(_ error: Error) {
        print("Error occurred: \(error)")
    }
    
    var requestCount: Int = 0
    var baseURL: String = "https://api.example.com"
}

// @Dummy
struct APIConfiguration {
    let baseURL: String
    let apiKey: String
    let timeout: TimeInterval
    
    func isValid() -> Bool {
        return !baseURL.isEmpty && !apiKey.isEmpty
    }
    
    mutating func updateTimeout(_ newTimeout: TimeInterval) {
        timeout = newTimeout
    }
}

// @Stub
func authenticateUser(username: String, password: String) async throws -> String {
    // Simulate authentication logic
    if username.isEmpty || password.isEmpty {
        throw AuthenticationError.invalidCredentials
    }
    return "auth_token_\(username)"
}

enum AuthenticationError: Error {
    case invalidCredentials
    case networkError
    case serverError
}

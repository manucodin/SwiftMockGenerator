import Foundation

// Example demonstrating async/await support

// @Stub
protocol AsyncNetworkService {
    func fetchUserData(userId: String) async throws -> UserData
    func uploadFile(_ data: Data, to url: URL) async -> UploadResult
    func syncData() async throws
}

// @Spy  
class AsyncUserManager {
    func createUser(name: String, email: String) async throws -> User {
        // Implementation would validate and create user
        throw UserCreationError.invalidEmail
    }
    
    func updateUserProfile(_ user: User, newName: String) async -> Bool {
        // Implementation would update user profile
        return true
    }
    
    func deleteUser(withId id: String) async throws {
        // Implementation would delete user
    }
}

// @Dummy
enum UserCreationError: Error {
    case invalidEmail
    case duplicateUsername
    case networkError
    case serverError(String)
}

struct UserData {
    let id: String
    let name: String
    let email: String
    let createdAt: Date
}

struct User {
    let id: String
    let name: String
    let email: String
}

enum UploadResult {
    case success(URL)
    case failure(Error)
    case inProgress(Double)
}
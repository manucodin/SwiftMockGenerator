import Foundation

// @Stub
protocol NetworkServiceProtocol {
    func fetchData() async throws -> Data
    func uploadData(_ data: Data, completion: @escaping (Result<Bool, Error>) -> Void)
    func processRequest(with parameters: [String: Any]) -> String
}

// @Spy
class UserService {
    func loginUser(username: String, password: String) async throws -> Bool {
        // Implementation would go here
        return true
    }
    
    func logoutUser() {
        // Implementation would go here
    }
    
    func getCurrentUser() -> User? {
        // Implementation would go here
        return nil
    }
}

// @Dummy
enum UserRole {
    case admin
    case user
    case guest
    case moderator
}

// @Stub
func validateEmail(_ email: String) -> Bool {
    // Implementation would go here
    return email.contains("@")
}

// @Spy
func sendNotification(title: String, body: String, completion: @escaping (Bool) -> Void) {
    // Implementation would go here
    completion(true)
}

struct User {
    let id: String
    let username: String
    let email: String
    let role: UserRole
}

// @Dummy
class DatabaseManager {
    func saveUser(_ user: User) throws {
        // Implementation would go here
    }
    
    func fetchUser(by id: String) async -> User? {
        // Implementation would go here
        return nil
    }
    
    func deleteUser(with id: String) async throws -> Bool {
        // Implementation would go here
        return true
    }
}
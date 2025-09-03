import Foundation

// @Spy
protocol DataRepositoryProtocol {
    associatedtype Item
    
    func save(_ item: Item) throws
    func load(id: String) throws -> Item?
    func delete(id: String) throws
    func count() -> Int
    
    var items: [Item] { get }
}

// @Dummy
class UserRepository {
    private var users: [String: User] = [:]
    
    func createUser(name: String, email: String) -> User {
        let user = User(id: UUID().uuidString, name: name, email: email)
        users[user.id] = user
        return user
    }
    
    func findUser(by id: String) -> User? {
        return users[id]
    }
    
    func updateUser(_ user: User) {
        users[user.id] = user
    }
    
    func deleteUser(id: String) {
        users.removeValue(forKey: id)
    }
    
    var allUsers: [User] {
        return Array(users.values)
    }
}

struct User {
    let id: String
    let name: String
    let email: String
    
    var isValidEmail: Bool {
        return email.contains("@")
    }
}

// @Stub
protocol CacheProtocol {
    func store<T: Codable>(_ value: T, for key: String)
    func retrieve<T: Codable>(_ type: T.Type, for key: String) -> T?
    func remove(for key: String)
    func clear()
    
    var size: Int { get }
}

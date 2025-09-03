import XCTest
import Foundation

// This file shows how to use the generated mocks in your tests
// Run SwiftMockGenerator on the service files first to generate the mocks

// Example service that we want to test
class UserManager {
    private let networkService: NetworkServiceProtocol
    private let authService: AuthenticationService
    private let logger: LoggerProtocol?
    
    init(
        networkService: NetworkServiceProtocol,
        authService: AuthenticationService,
        logger: LoggerProtocol? = nil
    ) {
        self.networkService = networkService
        self.authService = authService
        self.logger = logger
    }
    
    func authenticateAndFetchUser(username: String, password: String) async throws -> User? {
        // First authenticate
        let isAuthenticated = try await authService.login(username: username, password: password)
        guard isAuthenticated else { return nil }
        
        // Then fetch user data
        let userData = try await networkService.fetchData()
        return parseUser(from: userData)
    }
    
    func updateUserSettings(_ user: User, settings: UserSettings) async -> Bool {
        logger?.log("Updating settings for user: \(user.id)")
        
        let success = await networkService.updateUser(user)
        if success {
            logger?.log("Successfully updated user settings")
        } else {
            logger?.log("Failed to update user settings")
        }
        
        return success
    }
    
    private func parseUser(from data: Data) -> User? {
        // Parsing implementation
        return User(id: "1", name: "Test User", email: "test@example.com")
    }
}

// MARK: - Test Cases

class UserManagerTests: XCTestCase {
    
    // Test using Stub - when you need working implementations
    func testAuthenticateAndFetchUser_WithStub() async throws {
        // Arrange
        let networkStub = NetworkServiceProtocolStub()
        let authStub = AuthenticationServiceStub()
        let userManager = UserManager(
            networkService: networkStub,
            authService: authStub
        )
        
        // Act
        let user = try await userManager.authenticateAndFetchUser(
            username: "testuser",
            password: "password"
        )
        
        // Assert
        XCTAssertNotNil(user)
        XCTAssertEqual(user?.name, "Test User")
    }
    
    // Test using Spy - when you need to verify interactions
    func testUpdateUserSettings_WithSpy() async throws {
        // Arrange
        let networkSpy = NetworkServiceProtocolSpy()
        let authSpy = AuthenticationServiceSpy()
        let loggerSpy = LoggerProtocolSpy()
        
        let userManager = UserManager(
            networkService: networkSpy,
            authService: authSpy,
            logger: loggerSpy
        )
        
        let user = User(id: "123", name: "Test", email: "test@example.com")
        let settings = UserSettings(theme: .dark, notifications: true)
        
        // Act
        let result = await userManager.updateUserSettings(user, settings: settings)
        
        // Assert - Verify method calls
        XCTAssertTrue(networkSpy.verifyUpdateUserCalled())
        XCTAssertTrue(networkSpy.verifyUpdateUserCalledWith(user))
        XCTAssertEqual(networkSpy.updateUserCallCount, 1)
        
        // Verify logging
        XCTAssertTrue(loggerSpy.verifyLogCalled())
        XCTAssertTrue(loggerSpy.logCallCount >= 1)
    }
    
    // Test using Dummy - when dependencies won't be called
    func testUserManagerInitialization() {
        // Arrange - Using dummies since we're not calling their methods
        let networkDummy = NetworkServiceProtocolDummy()
        let authDummy = AuthenticationServiceDummy()
        
        // Act
        let userManager = UserManager(
            networkService: networkDummy,
            authService: authDummy
        )
        
        // Assert - Just verify initialization
        XCTAssertNotNil(userManager)
    }
    
    // Test combining different mock types
    func testComplexScenario() async throws {
        // Arrange - Mix of mock types based on needs
        let networkSpy = NetworkServiceProtocolSpy()  // Need to verify network calls
        let authStub = AuthenticationServiceStub()     // Need working auth
        let loggerDummy = LoggerProtocolDummy()        // Won't check logging
        
        let userManager = UserManager(
            networkService: networkSpy,
            authService: authStub,
            logger: loggerDummy
        )
        
        let user = User(id: "456", name: "Another User", email: "user@example.com")
        let settings = UserSettings(theme: .light, notifications: false)
        
        // Act
        let result = await userManager.updateUserSettings(user, settings: settings)
        
        // Assert - Focus on what matters for this test
        XCTAssertTrue(result)
        XCTAssertTrue(networkSpy.verifyUpdateUserCalledWith(user))
        // Don't need to verify auth or logging for this test
    }
}

// MARK: - Supporting Types

struct User {
    let id: String
    let name: String
    let email: String
}

struct UserSettings {
    let theme: Theme
    let notifications: Bool
}

enum Theme {
    case light
    case dark
    case auto
}

// These would be in separate files with mock annotations

protocol NetworkServiceProtocol {
    func fetchData() async throws -> Data
    func updateUser(_ user: User) async -> Bool
}

class AuthenticationService {
    func login(username: String, password: String) async throws -> Bool {
        return true
    }
}

protocol LoggerProtocol {
    func log(_ message: String)
}

// MARK: - Expected Generated Mocks
/*
 After running SwiftMockGenerator, you would have:
 
 1. NetworkServiceProtocolStub.swift
 2. NetworkServiceProtocolSpy.swift  
 3. NetworkServiceProtocolDummy.swift
 4. AuthenticationServiceStub.swift
 5. AuthenticationServiceSpy.swift
 6. AuthenticationServiceDummy.swift
 7. LoggerProtocolStub.swift
 8. LoggerProtocolSpy.swift
 9. LoggerProtocolDummy.swift
 
 Each with appropriate implementations based on the mock type.
*/
import Foundation

// Example demonstrating callback-based async patterns

// @Stub
protocol CallbackNetworkService {
    func request(
        url: URL,
        method: HTTPMethod,
        completion: @escaping (Result<Data, NetworkError>) -> Void
    )
    
    func downloadFile(
        from url: URL,
        progressHandler: @escaping (Double) -> Void,
        completion: @escaping (Result<URL, Error>) -> Void
    )
    
    func batchUpload(
        files: [Data],
        onProgress: @escaping (Int, Int) -> Void,
        onComplete: @escaping ([UploadResult]) -> Void
    )
}

// @Spy
class CallbackAuthService {
    func authenticate(
        credentials: Credentials,
        success: @escaping (AuthToken) -> Void,
        failure: @escaping (AuthError) -> Void
    ) {
        // Implementation would authenticate user
        success(AuthToken(token: "dummy-token"))
    }
    
    func refreshToken(
        _ token: AuthToken,
        completion: @escaping (Result<AuthToken, AuthError>) -> Void
    ) {
        // Implementation would refresh token
        completion(.success(token))
    }
}

// @Dummy
enum HTTPMethod: String {
    case GET = "GET"
    case POST = "POST"
    case PUT = "PUT"
    case DELETE = "DELETE"
    case PATCH = "PATCH"
}

// @Spy
func processPayment(
    amount: Double,
    card: CreditCard,
    onSuccess: @escaping (PaymentResult) -> Void,
    onFailure: @escaping (PaymentError) -> Void
) {
    // Implementation would process payment
    onSuccess(PaymentResult(transactionId: "12345", amount: amount))
}

// @Stub
func validateCreditCard(
    _ card: CreditCard,
    completion: @escaping (Bool, ValidationError?) -> Void
) {
    // Implementation would validate credit card
    completion(true, nil)
}

// Supporting types
struct Credentials {
    let username: String
    let password: String
}

struct AuthToken {
    let token: String
    let expiresAt: Date = Date().addingTimeInterval(3600)
}

enum AuthError: Error {
    case invalidCredentials
    case tokenExpired
    case networkError
}

enum NetworkError: Error {
    case noConnection
    case timeout
    case serverError(Int)
}

struct CreditCard {
    let number: String
    let expiryDate: String
    let cvv: String
}

struct PaymentResult {
    let transactionId: String
    let amount: Double
    let timestamp: Date = Date()
}

enum PaymentError: Error {
    case insufficientFunds
    case invalidCard
    case processingError
}

enum ValidationError: Error {
    case invalidNumber
    case expiredCard
    case invalidCVV
}
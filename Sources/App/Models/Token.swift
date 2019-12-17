import Authentication
import FluentPostgreSQL
import Vapor

final class Token: Codable {
    
    // MARK: Properties
    
    var id: Int?
    var token: String
    var userID: User.ID
    
    // MARK: Initialization
    
    init(token: String, userID: User.ID) {
        self.token = token
        self.userID = userID
    }
    
}

// MARK: - PostgreSQLUUIDModel

extension Token: PostgreSQLModel {}

// MARK: - Content

extension Token: Content {}

// MARK: - Migration

extension Token: Migration {
    
    static func prepare(on connection: PostgreSQLConnection) -> EventLoopFuture<Void> {
        return Database.create(self, on: connection) { builder in
            try addProperties(to: builder)
            
            // Create a foreign key constraint with a User
            builder.reference(from: \.userID, to: \User.id)
        }
    }
    
}

// MARK: Authentication.Token

extension Token: Authentication.Token {
    
    static let userIDKey: UserIDKey = \Token.userID
    
    typealias UserType = User
    
}

// MARK: - BearerAuthenticatable

extension Token: BearerAuthenticatable {
    
    static let tokenKey: TokenKey = \Token.token
    
}

// MARK: Utilities

extension Token {
    
    static func generate(for user: User) throws -> Token {
        let random = try CryptoRandom().generateData(count: 16)
        return try Token(token: random.base64EncodedString(), userID: user.requireID())
    }
    
}

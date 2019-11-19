import Authentication
import FluentPostgreSQL
import Vapor

final class User: Codable {
    
    // MARK: Properties
    
    var id: UUID?
    var username: String
    var password: String
    
    var todos: Children<User, Todo> {
        return children(\.userID)
    }
    
    // MARK: Initialization
    
    init(username: String, password: String) {
        self.username = username
        self.password = password
    }
    
}

// MARK: User + Public Representation

extension User {

    final class Public: Codable, Content {
        
        var id: UUID?
        var username: String
        
        init(id: UUID?, username: String) {
            self.id = id
            self.username = username
        }
        
    }
    
    func convertToPublic() -> User.Public {
        return User.Public(id: self.id, username: self.username)
    }
    
}

// MARK: - PostgreSQLUUIDModel

extension User: PostgreSQLUUIDModel {}

// MARK: - Content

extension User: Content {}

// MARK: - Parameter

extension User: Parameter {}

// MARK: - Migration

extension User: Migration {
 
    static func prepare(on connection: PostgreSQLConnection) -> EventLoopFuture<Void> {
        return Database.create(self, on: connection) { builder in
            // Add all the columns to the User table using the User's properties
            try addProperties(to: builder)
            // Add a unique index to the username
            builder.unique(on: \.username)
        }
    }
    
}

// MARK: - BasicAuthenticatable

extension User: BasicAuthenticatable {

    static let usernameKey: UsernameKey = \User.username
    static let passwordKey: PasswordKey = \User.password
    
}

// MARK: - TokenAuthenticatable

extension User: TokenAuthenticatable {
    
    typealias TokenType = Token
    
}

// MARK: - PasswordAuthenticatable

extension User: PasswordAuthenticatable {}

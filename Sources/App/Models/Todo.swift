import FluentPostgreSQL
import Vapor

final class Todo: Codable {
    
    // MARK: Properties
    
    var id: Int?
    var title: String
    var isCompleted: Bool
    var userID: User.ID
    
    var user: Parent<Todo, User> {
        return self.parent(\.userID)
    }
    
    // MARK: Initialization
    
    init(title: String,
         isCompleted: Bool = false,
         userID: User.ID) {
        self.title = title
        self.isCompleted = isCompleted
        self.userID = userID
    }
    
}

// MARK: - PostgreSQLModel

extension Todo: PostgreSQLModel {}

// MARK: - Migration

extension Todo: Migration {}

// MARK: - Content

extension Todo: Content {}

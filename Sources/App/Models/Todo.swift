import FluentPostgreSQL
import Vapor

final class Todo: Codable {
    
    // MARK: Properties
    
    var id: Int?
    var title: String
    var isCompleted: Bool
    
    // MARK: Initialization
    
    init(title: String, isCompleted: Bool = false) {
        self.title = title
        self.isCompleted = isCompleted
    }
    
}

// MARK: - PostgreSQLModel

extension Todo: PostgreSQLModel {}

// MARK: - Migration

extension Todo: Migration {}

// MARK: - Content

extension Todo: Content {}

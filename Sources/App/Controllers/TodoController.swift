import Authentication
import Fluent
import Vapor

struct TodoController: RouteCollection {
    
    func boot(router: Router) throws {
        let todoRoutes = router.grouped("api", "todos")
        
        let tokenAuthMiddleware = User.tokenAuthMiddleware()
        let guardAuthMiddleware = User.guardAuthMiddleware()
        let tokenAuthGroup = todoRoutes.grouped([
            tokenAuthMiddleware,
            guardAuthMiddleware
        ])
        
        tokenAuthGroup.post(use: createTodoHandler)
        tokenAuthGroup.patch(Todo.parameter, use: updateTodoHandler)
    }
    
    // MARK: Creating Todos
    
    func createTodoHandler(_ req: Request) throws -> Future<Todo> {
        let user = try req.requireAuthenticated(User.self)
        return req.content.get(String.self, at: "title").flatMap(to: Todo.self) { title in
            let todo = try Todo(title: title, userID: user.requireID())
            return todo.save(on: req)
        }
    }
    
    // MARK: Updating Todos
    
    func updateTodoHandler(_ req: Request) throws -> Future<Todo> {
        return try flatMap(to: Todo.self,
                           req.parameters.next(Todo.self),
                           req.content.decode(UpdateTodoData.self)) { todo, updates in
                            if let title = updates.title, !title.isEmpty {
                                todo.title = title
                            }
                            if let isCompleted = updates.isCompleted {
                                todo.isCompleted = isCompleted
                            }
                            
                            return todo.save(on: req)
        }
    }
    
}

struct UpdateTodoData: Content {
    var title: String?
    var isCompleted: Bool?
}

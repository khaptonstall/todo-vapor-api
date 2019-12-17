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
    
    func createTodoHandler(_ req: Request) throws -> FutureAPIResponse<Todo> {
        let user = try req.requireAuthenticated(User.self)
        return req.content.get(String.self, at: "title").flatMap(to: APIResponse<Todo>.self) { title in
            let todo = try Todo(title: title, userID: user.requireID())
            return todo.save(on: req).toAPIResponse()
        }
    }
    
    // MARK: Updating Todos
    
    func updateTodoHandler(_ req: Request) throws -> FutureAPIResponse<Todo> {
        return try flatMap(to: APIResponse<Todo>.self,
                           req.parameters.next(Todo.self),
                           req.content.decode(UpdateTodoData.self)) { todo, updates in
                            if let title = updates.title, !title.isEmpty {
                                todo.title = title
                            }
                            if let isCompleted = updates.isCompleted {
                                todo.isCompleted = isCompleted
                            }
                            
                            return todo.save(on: req).toAPIResponse()
        }
    }
    
}

struct UpdateTodoData: Content {
    var title: String?
    var isCompleted: Bool?
}

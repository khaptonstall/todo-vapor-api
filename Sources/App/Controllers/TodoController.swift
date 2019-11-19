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
    }
    
    func createTodoHandler(_ req: Request) throws -> Future<Todo> {
        let user = try req.requireAuthenticated(User.self)
        return req.content.get(String.self, at: "title").flatMap(to: Todo.self) { title in
            let todo = try Todo(title: title, userID: user.requireID())
            return todo.save(on: req)
        }
    }
    
}

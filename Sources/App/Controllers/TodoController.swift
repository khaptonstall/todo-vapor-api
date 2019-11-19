import Fluent
import Vapor

struct TodoController: RouteCollection {
    
    func boot(router: Router) throws {
        let todoRoutes = router.grouped("api", "todos")
        
        todoRoutes.post(use: createTodoHandler)
    }
    
    func createTodoHandler(_ req: Request) throws -> Future<Todo> {
        return try req.content.decode(Todo.self).flatMap(to: Todo.self) { todo in
            return todo.save(on: req)
        }
    }
    
}

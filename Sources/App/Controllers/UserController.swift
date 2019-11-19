import Authentication
import FluentPostgreSQL
import Vapor

struct UserController: RouteCollection {
    
    func boot(router: Router) throws {
        let usersRoute = router.grouped("api", "users")
                
        let basicAuthMiddleware = User.basicAuthMiddleware(using: BCryptDigest())
        let basicAuthGroup = usersRoute.grouped([basicAuthMiddleware])
        basicAuthGroup.post("login", use: loginHandler)
        
        usersRoute.post(CreateUserData.self, use: createHandler)
        
        let tokenAuthMiddleware = User.tokenAuthMiddleware()
        let guardAuthMiddleware = User.guardAuthMiddleware()
        let tokenAuthGroup = usersRoute.grouped([
            tokenAuthMiddleware,
            guardAuthMiddleware
        ])
        
        tokenAuthGroup.get(User.parameter, "todos", use: getTodosHandler)
    }
    
    // MARK: Registration/Login
    
    func createHandler(_ req: Request, data: CreateUserData) throws -> Future<Token> {
        let password = try BCrypt.hash(data.password)
        let user = User(username: data.username, password: password)
        return user.save(on: req).flatMap(to: Token.self) { user in
            return try Token.generate(for: user).save(on: req)
        }
    }
    
    func loginHandler(_ req: Request) throws -> Future<Token> {
        let user = try req.requireAuthenticated(User.self)
        let token = try Token.generate(for: user)
        return token.save(on: req)
    }
    
    // MARK: Fetching Todos
    
    func getTodosHandler(_ req: Request) throws -> Future<[Todo]> {
        let authenticatedUserID = try req.requireAuthenticated(User.self).requireID()
        let filterByIsCompleted = (try? req.query.get(Bool.self, at: "isCompleted")) ?? false
        
        return try req.parameters
            .next(User.self)
            .flatMap(to: [Todo].self) { requestedUser in
                let requestedUserID = try requestedUser.requireID()
                guard requestedUserID == authenticatedUserID else {
                    throw Abort(.unauthorized)
                }
                
                if filterByIsCompleted {
                    return try requestedUser.todos
                        .query(on: req)
                        .filter(\.isCompleted == filterByIsCompleted)
                        .all()
                } else {
                    return try requestedUser.todos.query(on: req).all()
                }
            }
    }
}

struct CreateUserData: Content, Validatable, Reflectable {
    let username: String
    let password: String
    
    static func validations() throws -> Validations<CreateUserData> {
        var validations = Validations(CreateUserData.self)
        try validations.add(\.username, .alphanumeric && .count(4...))
        try validations.add(\.password, .count(8...))
        return validations
    }
}

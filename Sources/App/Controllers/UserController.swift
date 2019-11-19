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
    }
    
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

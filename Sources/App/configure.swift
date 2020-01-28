import Authentication
import FluentPostgreSQL
import Vapor

/// Called before your application initializes.
public func configure(_ config: inout Config, _ env: inout Environment, _ services: inout Services) throws {
    // Register providers first
    try services.register(FluentPostgreSQLProvider())
    try services.register(AuthenticationProvider())

    // Register routes to the router
    let router = EngineRouter.default()
    try routes(router)
    services.register(router, as: Router.self)
    services.register(APIErrorResponseMiddleware.self)

    // Register middleware
    var middlewares = MiddlewareConfig() // Create _empty_ middleware config
    // middlewares.use(FileMiddleware.self) // Serves files from `Public/` directory
    middlewares.use(APIErrorResponseMiddleware.self) // Catches errors and converts to HTTP response
    services.register(middlewares)

    // Configure a database
    var databases = DatabasesConfig()
    
    let databaseConfig = PostgreSQLDatabaseConfig(hostname: "localhost",
                                                  username: "vapor",
                                                  database: "vapor",
                                                  password: "password")
    let database = PostgreSQLDatabase(config: databaseConfig)
    databases.add(database: database, as: .psql)
    
    services.register(databases)

    // Configure migrations
    var migrations = MigrationConfig()
    migrations.add(model: User.self, database: .psql)
    migrations.add(model: Todo.self, database: .psql)
    migrations.add(model: Token.self, database: .psql)
    services.register(migrations)
    
    //This adds the Fluent commands to your application, which allows you to manually run migrations.
     // It also allows you to revert your migrations.
    var commandConfig = CommandConfig.default()
    commandConfig.useFluentCommands()
    services.register(commandConfig)
}

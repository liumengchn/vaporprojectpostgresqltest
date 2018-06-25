import FluentPostgreSQL
import Vapor


/// Called before your application initializes.
public func configure(_ config: inout Config, _ env: inout Environment, _ services: inout Services) throws {

    /// Register routes to the router
    let router = EngineRouter.default()
    try routes(router)
    services.register(router, as: Router.self)

    /// Register middleware
    var middlewares = MiddlewareConfig() // Create _empty_ middleware config
    /// middlewares.use(FileMiddleware.self) // Serves files from `Public/` directory
    middlewares.use(ErrorMiddleware.self) // Catches errors and converts to HTTP response
    services.register(middlewares)

    /*************************************** FluentSQLite ************************************/
    //    /// Register providers first 1.
    //    try services.register(FluentSQLiteProvider())
    //
    //    // Configure a SQLite database 2.
    ////    let sqlite = try SQLiteDatabase(storage: .memory)
    //    let sqlite = try SQLiteDatabase(storage: .file(path: "/Users/liumengchen/Documents/vaporProject/sqlite_dir/db.sqlite"))
    //
    //    /// Register the configured SQLite database to the database config.
    //    var databases = DatabasesConfig()
    //    databases.add(database: sqlite, as: .sqlite)
    //    services.register(databases)
    //
//        /// Configure migrations 3.
//        var migrations = MigrationConfig()
//        migrations.add(model: Acronym.self, database: .sqlite)
//        services.register(migrations)

    /*************************************** FluentPostgreSQL ************************************/
    /// Register providers first 1.
    try services.register(FluentPostgreSQLProvider())
    
    // Configure a SQLite database 2.
    var databases = DatabasesConfig()
    
    //3. 本地数据库启用
    let databaseConfig = PostgreSQLDatabaseConfig(hostname: "localhost",
                                                  port:     5432,
                                                  username: "vapor",
                                                  database: "vapor"
//                                                  password: "password"
    )
    let database = PostgreSQLDatabase(config: databaseConfig)
    databases.add(database: database, as: .psql)
    services.register(databases)
    
//    //4. vapor cloud数据库启用 git commit -am "Use PostgreSQL as the database"  git push
//    let host_name = Environment.get("DATABASE_HOSTNAME") ?? "localhost"
//    let user_name = Environment.get("DATABASE_USER") ?? "vapor"
//    let database_Name = Environment.get("DATABASE_DB") ?? "vapor"
//    let user_password = Environment.get("DATABASE_PASSWORD") ?? "password"
//
//    let database_config = PostgreSQLDatabaseConfig(hostname: host_name,
//                                                   port: 5432,
//                                                   username: user_name,
//                                                   database: database_Name,
//                                                   password: user_password
//    )
//    let database = PostgreSQLDatabase(config: database_config)
//    databases.add(database: database, as: .psql)
//    services.register(databases)
    
    //4.
    /// Configure migrations 3.
    var migrations = MigrationConfig()
    migrations.add(model: Acronym.self, database: .psql)
    services.register(migrations)
    
}

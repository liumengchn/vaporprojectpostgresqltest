import Vapor

/// Register your application's routes here.
public func routes(_ router: Router) throws {
    // Basic "Hello, world!" example
    router.get("hello") { req in
        return "Hello, world!"
    }
    
    
    router.post("api" , "acronyms") { request -> Future<Acronym> in
        
        return try request.content.decode(Acronym.self).flatMap(to: Acronym.self) { acronym in
            // 3
            return acronym.save(on: request)
        }
    }

    
    
}

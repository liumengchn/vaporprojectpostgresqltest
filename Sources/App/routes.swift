import Vapor

import Fluent

/// Register your application's routes here.
public func routes(_ router: Router) throws {
    // Basic "Hello, world!" example
    router.get("hello") { req in
        return "Hello, world!"
    }
    
//    GET https://localhost:8080/api/acronyms/: get all the acronyms.
//    POST https://localhost:8080/api/acronyms: create a new acronym.
//    GET https://localhost:8080/api/acronyms/1: get the acronym with ID 1.
//    PUT https://localhost:8080/api/acronyms/1: update the acronym with ID 1.
//    DELETE https://localhost:8080/api/acronyms/1: delete the acronym with ID 1.
    
    // CREATE
    router.post("api" , "acronyms") { request -> Future<Acronym> in
        
        return try request.content.decode(Acronym.self).flatMap(to: Acronym.self) { acronym in
            // 3
            return acronym.save(on: request)
        }
    }
    
    // Retrieve all acronyms
    router.get("api", "acronyms") { request -> Future<[Acronym]> in
        
        return Acronym.query(on: request).all()
    }
    
    // Retrieve a single acronym http://localhost:8080/api/acronyms/1
    router.get("api", "acronyms" , Acronym.parameter) { request -> Future<Acronym> in
        
        return try request.parameters.next(Acronym.self)
    }
    
    // Update http://localhost:8080/api/acronyms/1 参数
    router.put("api", "acronyms" , Acronym.parameter) { request -> Future<Acronym> in
        
        return try flatMap(to: Acronym.self, request.parameters.next(Acronym.self), request.content.decode(Acronym.self)) { acronym, update_acronym in
            
            acronym.short = update_acronym.short
            acronym.long = update_acronym.long
            
            return acronym.save(on: request)
        }
    }
    
    // Delete  http://localhost:8080/api/acronyms/3
    router.delete("api", "acronyms" , Acronym.parameter) { request -> Future<HTTPStatus> in
        
        return try request.parameters.next(Acronym.self).delete(on: request).transform(to: HTTPStatus.noContent)
    }
    
    /* ------------------------------------- Fluent queries ------------------------------------- */
    // Filter    import Fluent  http://localhost:8080/api/acronyms/search?term=liumengchen05
    router.get("api", "acronyms" , "search") { request -> Future<[Acronym]> in
        
        guard let search_term = request.query[String.self , at: "term"] else { throw Abort(.badRequest)}
        
        //过滤
//        return Acronym.query(on: request).filter(\Acronym.short == search_term).all()
        
        //搜索多个字段 只匹配短属性和长属性相同的首字母缩略词
        return  Acronym.query(on: request).group(.or) { or in
            
             or.filter(\Acronym.short == search_term)
             or.filter(\Acronym.long == search_term)
            
        }.all()
    }
    
    //First result 有时，应用程序只需要查询的第一个结果。为此创建一个特定的处理程序可以确保数据库只返回一个结果，而不是将所有结果加载到内存中。创建一个新的路由处理程序，以返回路由末尾的首字母缩写(_:):
    router.get("api", "acronyms" , "first") { request -> Future<Acronym> in
        
        return Acronym.query(on: request).first().map(to: Acronym.self) { acronym in
            
            guard let acronym = acronym else { throw Abort(.notFound)}
            
            return acronym
            
        }
    }
    
    //Sorting results  对返回结果进行排序
    router.get("api", "acronyms" , "sorted") { request -> Future<[Acronym]> in
        
        return Acronym.query(on: request).sort(\Acronym.id, .ascending).all()
    }
    
}

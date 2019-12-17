//
//  APIResponse.swift
//  App
//
//  Created by Kyle Haptonstall on 12/17/19.
//

import Foundation
import Vapor

typealias FutureAPIResponse<T: Codable> = Future<APIResponse<T>>

/// The response object that should be returned to the client.
///
/// Formats the response json as:
/// ```
/// {
/// "data": T
/// }
/// ```
struct APIResponse<T: Codable>: Content {
    let data: T
}

extension Future where T: Codable {
    
    func toAPIResponse() -> Future<APIResponse<T>> {
        self.map(to: APIResponse<T>.self) { object in
            return APIResponse<T>(data: object)
        }
    }
    
}

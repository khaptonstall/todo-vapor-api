//
//  Future+APIResponse.swift
//  App
//
//  Created by Kyle Haptonstall on 1/28/20.
//

import Foundation
import Vapor

typealias FutureAPIResponse<T: Codable> = Future<APIResponse<T>>

extension Future where T: Codable {
    
    func toAPIResponse() -> Future<APIResponse<T>> {
        self.map(to: APIResponse<T>.self) { object in
            return APIResponse<T>(data: object)
        }
    }
    
}

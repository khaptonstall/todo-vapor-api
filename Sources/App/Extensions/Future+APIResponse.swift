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

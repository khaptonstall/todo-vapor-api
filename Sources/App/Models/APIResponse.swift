import Foundation
import Vapor

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

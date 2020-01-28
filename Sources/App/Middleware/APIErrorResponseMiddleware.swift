import Foundation
import Vapor

/// Error middleware which will format error responses as `APIResponse` objects.
final class APIErrorResponseMiddleware: Middleware {
    
    private struct ErrorResponse: Codable {
        /// The status code for the error.
        let status: Int
        /// A displayable title for the error.
        let title: String
        /// A displayable message for the error.
        let message: String
    }
    
    /// A closure which takes a `Request` and `Error` and produces a `Response`.
    typealias ErrorResponseClosure = (Request, Error) -> (Response)
    
    private let closure: ErrorResponseClosure
    
    
    /// Creates a `APIErrorResponseMiddleware`.
    /// - Parameter closure: The closure to execute when the request results in an error.
    init(_ closure: @escaping ErrorResponseClosure) {
        self.closure = closure
    }
    
    /// Creates an instance of `APIErrorResponseMiddleware` which will produce
    /// errors formatted as `APIResponse` objects.
    static func defaultErrorHandler() -> APIErrorResponseMiddleware {
        return .init { request, error in
            let status: HTTPStatus
            let title: String
            let message: String
            
            switch error {
            case let abort as AbortError:
                status = abort.status
                title = "Error"
                message = abort.reason
            case let validationError as ValidationError:
                status = .badRequest
                title = "Validation Error"
                message = validationError.reason
            case let multipartError as MultipartError:
                status = .badRequest
                title = MultipartError.readableName
                message = multipartError.reason
            default:
                status = .internalServerError
                title = "Internal Server Error"
                message = "Please try again later."
            }
            
            let response = request.response(http: .init(status: status, headers: [:]))
            
            do {
                // Create an ErrorResponse and wrap it in a formatted APIResponse object.
                let errorResponse = ErrorResponse(status: Int(status.code),
                                                  title: title,
                                                  message: message)
                let apiResponse: APIResponse<ErrorResponse> = APIResponse(data: errorResponse)
                response.http.body = try HTTPBody(data: JSONEncoder().encode(apiResponse))
                response.http.headers.replaceOrAdd(name: .contentType,
                                                   value: "application/json; charset=utf-8")
            } catch {
                // Fallback to a generic error if we fail to encode a formatted JSON error.
                response.http.body = HTTPBody(string: "Something went wrong")
                response.http.headers.replaceOrAdd(name: .contentType,
                                                   value: "text/plain; charset=utf-8")
            }
            
            return response
        }
    }
    
    func respond(to request: Request, chainingTo next: Responder) throws -> EventLoopFuture<Response> {
        let response: Future<Response>
        do {
            response = try next.respond(to: request)
        } catch {
            response = request.eventLoop.newFailedFuture(error: error)
        }
        
        return response.catchFlatMap { error in
            // Pass the request and error through our error handling closure
            return request.future(self.closure(request, error))
        }
    }
    
}

// MARK: - ServiceType

extension APIErrorResponseMiddleware: ServiceType {
    
    static func makeService(for container: Container) throws -> APIErrorResponseMiddleware {
        return .defaultErrorHandler()
    }
    
}

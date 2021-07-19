import Foundation

extension HTTPURLResponse {
    var isError: Bool {
        !(200...399).contains(statusCode)
    }
}

import Foundation

internal extension URL {
    init(_ string: StaticString) {
        guard let url = URL(string: "\(string)") else {
            preconditionFailure("Invalid static URL string: \(string)")
        }

        self = url
    }
}

internal extension URL {
    func valueOf(queryParameter name: String) -> String? {
        guard let url = URLComponents(url: self, resolvingAgainstBaseURL: true) else { return nil }
        return url.queryItems?.first(where: { $0.name == name })?.value
    }
}

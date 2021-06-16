import Foundation

internal extension URL {
    func valueOf(queryParameter name: String) -> String? {
        guard let url = URLComponents(url: self, resolvingAgainstBaseURL: true) else { return nil }
        return url.queryItems?.first(where: { $0.name == name })?.value
    }
}

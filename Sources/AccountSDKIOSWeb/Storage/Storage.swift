import Foundation

internal protocol Storage {
    func setValue(_ value: Any?, forKey key: String)
    func value(forKey key: String) -> Any?
    func removeValue(forKey key: String)
}

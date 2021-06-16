import Foundation

internal protocol Storage {
    func setValue(_ value: Data, forKey key: String)
    func value(forKey key: String) -> Data?
    func removeValue(forKey key: String)
}

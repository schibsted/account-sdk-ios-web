import Foundation

private class CacheWrapper<V> {
    let value: V

    init(value: V) {
        self.value = value
    }
}

class Cache<V> {
    private let cache = NSCache<NSString, CacheWrapper<V>>()

    func object(forKey: String) -> V? {
        return cache.object(forKey: forKey as NSString)?.value
    }

    func setObject(_ object: V, forKey: String) {
        cache.setObject(CacheWrapper(value: object), forKey: forKey as NSString)
    }
}

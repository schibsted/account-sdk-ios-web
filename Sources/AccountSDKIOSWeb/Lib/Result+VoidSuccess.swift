import Foundation

extension Result where Success == Void {
    public static func success() -> Self { .success(()) }
}

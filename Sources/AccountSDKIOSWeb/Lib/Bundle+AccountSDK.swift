import Foundation

#if !SPM
extension Bundle {
  static var module: Bundle {
      Bundle(for: SimplifiedLoginViewController.self)
  }
}
#endif

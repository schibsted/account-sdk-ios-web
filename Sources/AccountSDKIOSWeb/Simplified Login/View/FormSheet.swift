import UIKit
import SwiftUI

@available(iOS 13.0, *)
class FormSheetWrapper<Content: View>: UIViewController, UIPopoverPresentationControllerDelegate {
    
    var content: () -> Content
    var onDismiss: (() -> Void)?
    
    private var hostViewController: UIHostingController<Content>?
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    init(content: @escaping () -> Content) {
        self.content = content
        super.init(nibName: nil, bundle: nil)
    }
    
    func show() {
        guard hostViewController == nil else {
            return
        }
        let contentViewController = UIHostingController(rootView: content())
        contentViewController.view.sizeToFit()
        contentViewController.preferredContentSize = .init(width: 450, height: 480)
        contentViewController.modalPresentationStyle = .formSheet
        contentViewController.presentationController?.delegate = self
        
        hostViewController = contentViewController
        self.present(contentViewController, animated: true, completion: nil)
    }
    
    func hide() {
        guard let vc = self.hostViewController, !vc.isBeingDismissed else {
            return
        }
        dismiss(animated: true, completion: nil)
        hostViewController = nil
    }
    
    func presentationControllerWillDismiss(_ presentationController: UIPresentationController) {
        hostViewController = nil
        self.onDismiss?()
    }
}

@available(iOS 13.0, *)
struct FormSheet<Content: View> : UIViewControllerRepresentable {
    
    @Binding var show: Bool
    
    let content: () -> Content
    
    func makeUIViewController(context: UIViewControllerRepresentableContext<FormSheet<Content>>) -> FormSheetWrapper<Content> {
        
        let wrapper = FormSheetWrapper(content: content)
        wrapper.onDismiss = {
            self.show = false
        }
        return wrapper
    }
    
    func updateUIViewController(_ uiViewController: FormSheetWrapper<Content>,
                                context: UIViewControllerRepresentableContext<FormSheet<Content>>) {
        if show {
            uiViewController.show()
        }
        else {
            uiViewController.hide()
        }
    }
}

@available(iOS 13.0, *)
extension View {
    public func formSheet<Content: View>(isPresented: Binding<Bool>,
                                         @ViewBuilder content: @escaping () -> Content) -> some View {
        self.background(FormSheet(show: isPresented,
                                  content: content))
    }
}

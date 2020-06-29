import UIKit

extension UIViewController {
    
  public func present(_ viewController: UIViewController,
               animated: Bool,
               presentationStyle: UIModalPresentationStyle,
               completion: (() -> Void)? = nil
  ) {
    viewController.modalPresentationStyle = presentationStyle
    present(viewController, animated: animated, completion: completion)
  }
    
}

extension UIViewController {
    func hideKeyboardWhenTappedAround() {
        let tapGesture = UITapGestureRecognizer(target: self,
                                                action: #selector(hideKeyboard))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
    }

    @objc func hideKeyboard() {
        view.endEditing(true)
    }
}

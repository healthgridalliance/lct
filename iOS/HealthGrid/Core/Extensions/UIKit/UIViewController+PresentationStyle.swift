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

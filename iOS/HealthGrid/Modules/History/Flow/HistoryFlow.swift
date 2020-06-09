import Foundation
import RxFlow
import RxCocoa
import UIKit
import SwiftEntryKit

public class HistoryFlow: Flow {

    public var root: Presentable = HistoryViewController()
    var viewController: HistoryViewController { return root as! HistoryViewController }
    
    private let viewModel: HistoryViewModel
    
    public init(viewModel: HistoryViewModel) {
        self.viewModel = viewModel
        
        viewController.set(viewModel: viewModel)
    }
    
    open func navigate(to step: Step) -> FlowContributors {
        guard let step = step as? HistorySteps else { return .none }
        
        switch step {
        case .close:
            self.viewController.dismiss(animated: true, completion: nil)
            return .end(forwardToParentFlowWithStep: step)
        case .tip: return showTip()
        }
    }
    
    private func showTip() -> FlowContributors {
        let popup = DatesTipPopup()
        SwiftEntryKit.display(entry: popup, using: EKAttributes.tipPopupDisplayAttributes)
        return .none
    }
    
}

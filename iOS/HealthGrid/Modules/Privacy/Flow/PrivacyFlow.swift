import Foundation
import RxFlow
import RxCocoa
import UIKit

public class PrivacyFlow: Flow {

    public var root: Presentable = PrivacyViewController()
    var viewController: PrivacyViewController { return root as! PrivacyViewController }
    
    private let viewModel: PrivacyViewModel
    
    public init(viewModel: PrivacyViewModel, type: PrivacyViewControllerType) {
        self.viewModel = viewModel
        
        viewController.set(viewModel: viewModel, type: type)
    }
    
    open func navigate(to step: Step) -> FlowContributors {
        guard let step = step as? PrivacySteps else { return .none }
        
        switch step {
        case .back:
            if let navigationController = self.viewController.navigationController {
                navigationController.popViewController(animated: true)
            } else {
                self.viewController.dismiss(animated: true, completion: nil)
            }
            return .end(forwardToParentFlowWithStep: step)
        case .close:
            self.viewController.dismiss(animated: true, completion: nil)
            return .none
        case .agreed:
            self.viewController.navigationController?.dismiss(animated: true, completion: nil)
            return .end(forwardToParentFlowWithStep: step)
        case .checkExposure: return showCheckExposure()
        }
    }
    
    private func showCheckExposure() -> FlowContributors {
        let dataSource = CheckExposureDataSource()
        let flow = CheckExposureFlow(dataSource: dataSource)
        Flows.use(flow, when: .ready) {  [unowned self] (root: UINavigationController) in
            root.setNavigationBarHidden(true, animated: false)
            self.viewController.present(root, animated: true, presentationStyle: .fullScreen)
        }
        return .one(flowContributor: .contribute(withNextPresentable: flow,
                                                 withNextStepper: OneStepper(withSingleStep: CheckExposureSteps.checkExposure)))
    }
    
}

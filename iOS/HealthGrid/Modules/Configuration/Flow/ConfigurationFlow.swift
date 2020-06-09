import Foundation
import RxFlow
import RxCocoa
import UIKit

public class ConfigurationFlow: Flow {

    public var root: Presentable = ConfigurationViewController()
    var viewController: ConfigurationViewController { return root as! ConfigurationViewController }
    
    private let viewModel: ConfigurationViewModel
    
    public init(viewModel: ConfigurationViewModel) {
        self.viewModel = viewModel
        
        viewController.set(viewModel: viewModel)
    }
    
    open func navigate(to step: Step) -> FlowContributors {
        guard let step = step as? ConfigurationSteps else { return .none }
        
        switch step {
        case .history: return .end(forwardToParentFlowWithStep: step)
        case .delete: return .end(forwardToParentFlowWithStep: step)
        case .privacy: return .end(forwardToParentFlowWithStep: step)
        case .requestPermission: return .one(flowContributor: .forwardToParentFlow(withStep: step))
        }
    }
    
}

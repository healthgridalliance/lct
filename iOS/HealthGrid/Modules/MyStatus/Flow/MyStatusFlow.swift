import Foundation
import RxFlow
import RxCocoa
import UIKit

public class MyStatusFlow: Flow {

    public var root: Presentable = MyStatusViewController()
    var viewController: MyStatusViewController { return root as! MyStatusViewController }
    
    private let viewModel: MyStatusViewModel
    
    public init(viewModel: MyStatusViewModel) {
        self.viewModel = viewModel
        
        viewController.set(viewModel: viewModel)
    }
    
    open func navigate(to step: Step) -> FlowContributors {
        guard let step = step as? MyStatusSteps else { return .none }
        
        switch step {
        case .exposurePopup: return .end(forwardToParentFlowWithStep: step)
        case .requestPermission: return .one(flowContributor: .forwardToParentFlow(withStep: step))
        }
    }
    
}

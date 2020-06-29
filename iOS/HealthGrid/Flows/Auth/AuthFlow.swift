import Foundation
import RxFlow
import UIKit

final class AuthFlow: Flow {

    var root: Presentable {
        return self.rootViewController
    }

    private let rootViewController: UINavigationController = {
        let nc = UINavigationController()
        let transition = CATransition()
        transition.duration = 0.3
        transition.type = CATransitionType.fade
        nc.view.layer.add(transition, forKey: nil)
        return nc
    }()

    func navigate(to step: Step) -> FlowContributors {
        guard let authStep = step as? AuthStep else {
            return .none
        }
        switch authStep {
        case .welcome: return navigateToWelcome()
        }
    }

    func navigateToWelcome() -> FlowContributors {
        return .none
    }
}

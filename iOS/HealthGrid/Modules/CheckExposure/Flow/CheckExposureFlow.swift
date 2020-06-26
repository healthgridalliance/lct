import Foundation
import RxFlow
import RxCocoa
import UIKit
import SwiftEntryKit

public class CheckExposureFlow: Flow {

    public var root: Presentable = UINavigationController()
    
    private var navigationController: UINavigationController? {
        return self.root as? UINavigationController
    }
    
    private let dataSource: CheckExposureDataSourceProtocol
    
    public init(dataSource: CheckExposureDataSourceProtocol) {
        self.dataSource = dataSource
    }
    
    open func navigate(to step: Step) -> FlowContributors {
        guard let step = step as? CheckExposureSteps else { return .none }
        
        switch step {
        case .checkExposure: return showCheckExposure()
        case .close:
            UIApplication.shared.keyWindow?.rootViewController?.dismiss(animated: true, completion: nil)
            return .none
        case .back:
            self.navigationController?.popViewController(animated: true)
            return .none
        case .result(let dates): return showResult(dates: dates)
        case .info(let dates): return showInfo(dates: dates)
        case .requestPermission: return .one(flowContributor: .forwardToParentFlow(withStep: step))
        }
    }
    
    private func showCheckExposure() -> FlowContributors {
        let viewController = CheckExposureViewController()
        let viewModel = CheckExposureViewModel(with: dataSource)
        viewController.set(viewModel: viewModel)
        navigationController?.pushViewController(viewController, animated: true)
        return .one(flowContributor: .contribute(withNextPresentable: viewController, withNextStepper: viewModel))
    }
    
    private func showResult(dates: [String]) -> FlowContributors {
        let viewController = CheckExposureResultViewController()
        let viewModel = CheckExposureResultViewModel()
        viewController.set(viewModel: viewModel, dates: dates)
        navigationController?.pushViewController(viewController, animated: true)
        return .one(flowContributor: .contribute(withNextPresentable: viewController, withNextStepper: viewModel))
    }
    
    private func showInfo(dates: [String]) -> FlowContributors {
        let viewController = CheckExposuresViewController()
        let viewModel = CheckExposuresViewModel()
        viewController.set(viewModel: viewModel, dates: dates)
        navigationController?.pushViewController(viewController, animated: true)
        return .one(flowContributor: .contribute(withNextPresentable: viewController, withNextStepper: viewModel))
    }
    
}

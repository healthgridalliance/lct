import Foundation
import RxFlow
import RxCocoa
import UIKit

public class DiagnosisFlow: Flow {

    public var root: Presentable = UINavigationController()
    
    private var navigationController: UINavigationController? {
        return self.root as? UINavigationController
    }
    
    private let dataSource: DiagnosisDataSourceProtocol
    private var viewModel: DiagnosisVerifyViewModel?
    
    public init(dataSource: DiagnosisDataSourceProtocol) {
        self.dataSource = dataSource
    }
    
    open func navigate(to step: Step) -> FlowContributors {
        guard let step = step as? DiagnosisSteps else { return .none }
        
        switch step {
        case .close:
            self.navigationController?.dismiss(animated: true, completion: nil)
            return .none
        case .back:
            self.navigationController?.popViewController(animated: true)
            return .none
        case .notify: return showNotify()
        case .verify: return showVerify()
        case .shareLocationPopup(let code): return showShareLocationPopup(code: code)
        case .result: return showResult()
        }
    }
    
    private func showNotify() -> FlowContributors {
        let viewController = DiagnosisNotifyViewController()
        let viewModel = DiagnosisNotifyViewModel()
        viewController.set(viewModel: viewModel)
        navigationController?.pushViewController(viewController, animated: true)
        return .one(flowContributor: .contribute(withNextPresentable: viewController, withNextStepper: viewModel))
    }
    
    private func showVerify() -> FlowContributors {
        let viewController = DiagnosisVerifyViewController()
        viewModel = DiagnosisVerifyViewModel(with: dataSource)
        guard let viewModel = viewModel else { return .none }
        viewController.set(viewModel: viewModel)
        navigationController?.pushViewController(viewController, animated: true)
        return .one(flowContributor: .contribute(withNextPresentable: viewController, withNextStepper: viewModel))
    }
    
    private func showShareLocationPopup(code: String) -> FlowContributors {
        let alert = UIAlertController(title: "diagnosis_verify_alert_title".localized,
                                      message: "diagnosis_verify_alert_message".localized,
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "diagnosis_verify_alert_dont_allow".localized, style: .default, handler: { [unowned self] _ in
            self.viewModel?.steps.accept(DiagnosisSteps.close)
        }))
        alert.addAction(UIAlertAction(title: "diagnosis_verify_alert_allow".localized, style: .default, handler: { [unowned self] _ in
            self.viewModel?.code.onNext(code)
        }))
        self.navigationController?.present(alert, animated: true)
        return .none
    }
    
    private func showResult() -> FlowContributors {
        let viewController = DiagnosisResultViewController()
        let viewModel = DiagnosisResultViewModel()
        viewController.set(viewModel: viewModel)
        navigationController?.pushViewController(viewController, animated: true)
        return .one(flowContributor: .contribute(withNextPresentable: viewController, withNextStepper: viewModel))
    }
    
}

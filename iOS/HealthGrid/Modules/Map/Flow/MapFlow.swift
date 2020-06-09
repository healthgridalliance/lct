import Foundation
import RxFlow
import RxCocoa
import UIKit
import SwiftEntryKit

public class MapFlow: Flow {

    public var root: Presentable = MapViewController()
    var viewController: MapViewController { return root as! MapViewController }
    
    private let viewModel: MapViewModel
    
    public init(viewModel: MapViewModel) {
        self.viewModel = viewModel
        
        viewController.set(viewModel: viewModel)
    }
    
    open func navigate(to step: Step) -> FlowContributors {
        if case ConfigurationSteps.history = step {
            return showHistory()
        }
        if case ConfigurationSteps.delete = step {
            return showDeletePopup()
        }
        if case ConfigurationSteps.privacy = step {
            return showPrivacy()
        }
        if case ConfigurationSteps.requestPermission = step {
            return navigate(to: MapSteps.requestPermission)
        }
        if case PrivacySteps.back = step {
            return showConfiguration(delayed: true)
        }
        if case HistorySteps.close = step {
            return navigate(to: MapSteps.configuration(delayed: true))
        }
        if case MyStatusSteps.exposurePopup(let dates) = step {
            return showExposurePopup(with: dates)
        }
        if case MyStatusSteps.requestPermission = step {
            return navigate(to: MapSteps.requestPermission)
        }
        
        guard let step = step as? MapSteps else { return .none }
        
        switch step {
        case .myStatus: return showMyStatus()
        case .configuration: return showConfiguration()
        case .legend: return showLegendPopup()
        case .requestPermission: return showRequestPermissionPopup()
        }
    }
    
    private func showMyStatus() -> FlowContributors {
        let attributes = EKAttributes.controllerDefaultDisplayAttributes
        
        let dataSource = MyStatusDataSource()
        let viewModel = MyStatusViewModel(dataSource: dataSource)
        let flow = MyStatusFlow(viewModel: viewModel)
        
        SwiftEntryKit.display(entry: flow.viewController, using: attributes)
        return .one(flowContributor: .contribute(withNextPresentable: flow, withNextStepper: viewModel))
    }
    
    private func showConfiguration(delayed: Bool = false) -> FlowContributors {
        let attributes = EKAttributes.controllerDefaultDisplayAttributes

        let viewModel = ConfigurationViewModel()
        let flow = ConfigurationFlow(viewModel: viewModel)
        
        let delay = delayed ? 0.3 : 0
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
           SwiftEntryKit.display(entry: flow.viewController, using: attributes)
        }
        return .one(flowContributor: .contribute(withNextPresentable: flow, withNextStepper: viewModel))
    }
    
    private func showLegendPopup() -> FlowContributors {
        let popup = MapLegendPopup()
        SwiftEntryKit.display(entry: popup, using: EKAttributes.popupDefaultDisplayAttributes)
        return .none
    }
    
    private func showDeletePopup() -> FlowContributors {
        let alert = UIAlertController(title: "configuration_delete_title".localized,
                                      message: "configuration_delete_subtitle".localized,
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "cancel".localized, style: .default, handler: nil))
        alert.addAction(UIAlertAction(title: "delete".localized, style: .destructive, handler: { [unowned self] _ in
            self.viewModel.deleteAllData().disposed(by: self.viewController.disposeBag)
        }))
        self.viewController.present(alert, animated: true)
        return .none
    }
    
    private func showPrivacy() -> FlowContributors {
        let viewModel = PrivacyViewModel()
        let flow = PrivacyFlow(viewModel: viewModel, type: .configuration)
        Flows.use(flow, when: .ready) {  [unowned self] root in
            self.viewController.present(root, animated: true, completion: nil)
        }
        
        return .one(flowContributor: .contribute(withNextPresentable: flow, withNextStepper: viewModel))
    }
    
    private func showHistory() -> FlowContributors {
        let dataSource = HistoryDataSource()
        let viewModel = HistoryViewModel(dataSource: dataSource)
        let flow = HistoryFlow(viewModel: viewModel)
        Flows.use(flow, when: .ready) {  [unowned self] root in
            self.viewController.present(root, animated: true, completion: nil)
        }
        return .one(flowContributor: .contribute(withNextPresentable: flow, withNextStepper: viewModel))
    }
    
    private func showExposurePopup(with dates: [String]) -> FlowContributors {
        if dates.isEmpty {
            let alert = UIAlertController(title: "",
                                          message: "status_exposure_negative_message".localized,
                                          preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "ok".localized, style: .default, handler: nil))
            self.viewController.present(alert, animated: true)
        } else {
            let alert = UIAlertController(title: "status_exposure_positive_title".localized,
                                          message: nil,
                                          preferredStyle: .alert)
            let attributedMessage = NSMutableAttributedString(string: "status_exposure_positive_message".localized,
                                                              attributes: [.font: UIFont.systemFont(ofSize: 13)])
            attributedMessage.append(NSAttributedString(string: dates.map({"· " + $0}).joined(separator: "\n"),
                                                        attributes: [.font: UIFont.boldSystemFont(ofSize: 13)]))
            alert.setValue(attributedMessage, forKey: "attributedMessage")
            
            alert.addAction(UIAlertAction(title: "ok".localized, style: .default, handler: nil))
            self.viewController.present(alert, animated: true)
        }
        return .none
    }
    
    private func showRequestPermissionPopup() -> FlowContributors {
        LocationTracker.shared.requestPermission()
        return .none
    }
    
}

import UIKit
import RxSwift
import Reachability
import SwiftyUserDefaults

class RootNavigationController: UINavigationController {
    
    weak var viewModel: MainViewModel?
    
    private let reachability = try? Reachability()
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        setNavigationBarHidden(true, animated: false)
        
        NotificationCenter.default
            .addObserver(self,
                         selector:#selector(requestPermission),
                         name: UIApplication.willEnterForegroundNotification,
                         object: nil)
        
        setupReachability()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if Defaults[\.firstLaunch] {
            viewModel?.steps.accept(MainStep.onboarding(animated: true))
        }
    }
    
    @objc private func requestPermission() {
        guard !Defaults[\.firstLaunch] else { return }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            LocationTracker.shared.requestPermission()
        }
    }
    
    private func setupReachability() {
        reachability?.whenReachable = { [weak self] _ in
            guard let self = self else { return }
            self.viewModel?.steps.accept(MainStep.hideConnectionErrorAlert)
        }
        reachability?.whenUnreachable = { [weak self] _ in
            guard let self = self else { return }
            self.viewModel?.steps.accept(MainStep.showConnectionErrorAlert)
        }

        do {
            try reachability?.startNotifier()
        } catch {
            print("Unable to start reachability notifier")
        }
    }
    
}

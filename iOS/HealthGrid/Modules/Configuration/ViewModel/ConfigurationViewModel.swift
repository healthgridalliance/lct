import Foundation
import RxFlow
import RxSwift
import RxCocoa
import RxDataSources
import SwiftEntryKit

public final class ConfigurationViewModel: AppStepper {
    
    private var dataSource: RxTableViewSectionedReloadDataSource<SettingsSection>?
    private static let ReuseIdenfier = String(describing:  SettingsTableViewCell.self)
    private let sections: BehaviorSubject<[SettingsSection]> = BehaviorSubject(value: [])
    
    private let isTrackingOn: BehaviorRelay<Bool>
    private let isTrackingOff: BehaviorRelay<Bool>
    private let isTrackingOffForever: BehaviorRelay<Bool>
    private let disposeBag = DisposeBag()
    
    private let tracker = LocationTracker.shared
        
    public override init() {
        isTrackingOn = BehaviorRelay(value: tracker.locationStatus == .on)
        isTrackingOff = BehaviorRelay(value: tracker.locationStatus == .off)
        isTrackingOffForever = BehaviorRelay(value: tracker.locationStatus == .disabled)
        
        super.init()
        
        initRxDataSource()
        setupSections()
    }
    
    private func initRxDataSource() {
        dataSource = RxTableViewSectionedReloadDataSource(configureCell: { [weak self] (_, tv, idx, item) in
            guard let self = self else { return UITableViewCell(frame: .zero) }
            let cell = tv.dequeueReusableCell(withIdentifier: ConfigurationViewModel.ReuseIdenfier, for: idx) as! SettingsTableViewCell
            let output = cell.configure(
                SettingsCellViewModel.Input(
                    isSelected: item.isSelected),
                type: item.type
                )
            self.handleSettingsCellOutput(output).disposed(by: cell.disposeBag)
            return cell
        })
    }
    
    private func setupSections() {
        let items = [SettingsCellItem(type: .history),
                     SettingsCellItem(type: .trackingOn, isSelected: isTrackingOn),
                     SettingsCellItem(type: .trackingOff, isSelected: isTrackingOff),
                     SettingsCellItem(type: .trackingOffForever, isSelected: isTrackingOffForever),
                     SettingsCellItem(type: .deleteData),
                     SettingsCellItem(type: .privacy)]
        sections.onNext([.statusSettings(items: items)])
    }
    
    private func updateSelection() {
        self.isTrackingOn.accept(self.tracker.locationStatus == .on)
        self.isTrackingOff.accept(self.tracker.locationStatus == .off)
        self.isTrackingOffForever.accept(self.tracker.locationStatus == .disabled)
    }
    
    private func handleSettingsCellOutput(_ output: SettingsCellViewModel.Output) -> Disposable {
        let actionEventBinding = output.actionEvent.subscribe(onNext: { [weak self] value in
            guard let self = self else { return }
            switch value {
            case .history:
                if LocationTracker.shared.isLocationEnabled.value {
                    SwiftEntryKit.dismiss {
                        self.steps.accept(ConfigurationSteps.history)
                    }
                } else {
                    self.steps.accept(ConfigurationSteps.requestPermission)
                }
                return
            case .trackingOn:
                self.tracker.startTracking()
                    .subscribe(onNext: { [weak self] available in
                        guard let self = self else { return }
                        if available {
                            self.updateSelection()
                        } else {
                            self.steps.accept(ConfigurationSteps.requestPermission)
                        }
                    })
                    .disposed(by: self.disposeBag)
            case .trackingOff:
                self.tracker.stopTracking()
                    .subscribe(onNext: { [weak self] available in
                        guard let self = self else { return }
                        if available {
                            self.updateSelection()
                        } else {
                            self.steps.accept(ConfigurationSteps.requestPermission)
                        }
                })
                .disposed(by: self.disposeBag)
            case .trackingOffForever:
                self.tracker.disableTracking()
                    .subscribe(onNext: { [weak self] in
                        guard let self = self else { return }
                        self.updateSelection()
                    })
                    .disposed(by: self.disposeBag)
            case .deleteData:
                SwiftEntryKit.dismiss {
                    self.steps.accept(ConfigurationSteps.delete)
                }
            case .privacy:
                SwiftEntryKit.dismiss {
                    self.steps.accept(ConfigurationSteps.privacy)
                }
            default: break
            }
        })
        return Disposables.create([
            actionEventBinding
        ])
    }
    
    func bind(input: Input) -> Output {
        input.tableView.register(SettingsTableViewCell.self, forCellReuseIdentifier: ConfigurationViewModel.ReuseIdenfier)
        
        let binding = sections.bind(to: input.tableView.rx.items(dataSource: self.dataSource!))
        let locationPermissionBinding = LocationTracker.shared.state.subscribe(onNext: { [weak self] _ in
            guard let self = self else { return }
            self.updateSelection()
        })
        
        return Output(
            disposable: Disposables.create([
                binding,
                locationPermissionBinding
            ])
        )
    }
    
}

extension ConfigurationViewModel {
    struct Input {
        let tableView: UITableView
    }
    
    struct Output {
        let disposable: Disposable
    }
}

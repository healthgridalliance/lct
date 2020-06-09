import Foundation
import RxFlow
import RxSwift
import RxCocoa
import RxDataSources
import SwiftEntryKit

public final class MyStatusViewModel: AppStepper {
    
    private var tableViewDataSource: RxTableViewSectionedReloadDataSource<SettingsSection>?
    private static let ReuseIdenfier = String(describing:  SettingsTableViewCell.self)
    private let sections: BehaviorSubject<[SettingsSection]> = BehaviorSubject(value: [])
    
    private var dataSource: MyStatusDataSourceProtocol
    private let isHealthySelected: BehaviorRelay<Bool>
    private let isNotWellSelected: BehaviorRelay<Bool>
    private let isIllSelected: BehaviorRelay<Bool>
    
    private let isInfected = PublishSubject<Bool>()
    private let checkExposure = PublishSubject<Void>()
    
    private let myStatus = MyStatus(key: UserDefaults.myStatusKey)
    
    init(dataSource: MyStatusDataSourceProtocol) {
        self.dataSource = dataSource
        isHealthySelected = BehaviorRelay(value: myStatus.status == .good)
        isNotWellSelected = BehaviorRelay(value: myStatus.status == .well)
        isIllSelected = BehaviorRelay(value: myStatus.status == .ill)
        
        super.init()
        
        initRxDataSource()
        setupSections()
    }
    
    private func initRxDataSource() {
        tableViewDataSource = RxTableViewSectionedReloadDataSource(configureCell: { [weak self] (_, tv, idx, item) in
            guard let self = self else { return UITableViewCell(frame: .zero) }
            let cell = tv.dequeueReusableCell(withIdentifier: MyStatusViewModel.ReuseIdenfier, for: idx) as! SettingsTableViewCell
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
        let items = [SettingsCellItem(type: .healthy, isSelected: isHealthySelected),
                     SettingsCellItem(type: .notWell, isSelected: isNotWellSelected),
                     SettingsCellItem(type: .ill, isSelected: isIllSelected),
                     SettingsCellItem(type: .exposure)]
        sections.onNext([.statusSettings(items: items)])
    }
    
    private func handleSettingsCellOutput(_ output: SettingsCellViewModel.Output) -> Disposable {
        let actionEventBinding = output.actionEvent.subscribe(onNext: { [weak self] value in
            guard let self = self else { return }
            switch value {
            case .healthy:
                self.isHealthySelected.accept(true)
                self.isNotWellSelected.accept(false)
                self.isIllSelected.accept(false)
                self.isInfected.onNext(false)
            case .notWell:
                self.isHealthySelected.accept(false)
                self.isNotWellSelected.accept(true)
                self.isIllSelected.accept(false)
                self.isInfected.onNext(false)
            case .ill:
                self.isHealthySelected.accept(false)
                self.isNotWellSelected.accept(false)
                self.isIllSelected.accept(true)
                self.isInfected.onNext(true)
            case .exposure:
                if let _ = LocationTracker.shared.lastLocation.value {
                    self.checkExposure.onNext(())
                } else {
                    self.steps.accept(MyStatusSteps.requestPermission)
                }
            default: break
            }
        })
        return Disposables.create([
            actionEventBinding
        ])
    }
    
    func bind(input: Input) -> Output {
        input.tableView.register(SettingsTableViewCell.self, forCellReuseIdentifier: MyStatusViewModel.ReuseIdenfier)
        
        let binding = sections.bind(to: input.tableView.rx.items(dataSource: self.tableViewDataSource!))
        let isInfectedBinding = isInfected
            .distinctUntilChanged()
            .flatMap({self.dataSource.sendStatus($0)})
            .do(onNext: { [weak self] _ in
                guard let self = self else { return }
                if self.isHealthySelected.value {
                    self.myStatus.status = .good
                } else if self.isNotWellSelected.value {
                    self.myStatus.status = .well
                } else if self.isIllSelected.value {
                    self.myStatus.status = .ill
                }
            })
            .filter({_ in self.isIllSelected.value})
            .flatMap({_ in LocationTracker.shared.getAllData()})
            .flatMap({self.dataSource.sendHistory($0)})
            .subscribe()
        
        
        let checkExposureObservable = Observable.combineLatest(LocationTracker.shared.getAllData(),
                                                               self.dataSource.checkExposure())
        
        let checkExposureBinding = checkExposure
            .flatMap({checkExposureObservable})
            .flatMapLatest({LocationTracker.shared.checkExposure(userLocations: $0,
                                                                 heatzones: $1.result)})
            .subscribe(onNext: { [weak self] infectedDates in
                guard let self = self else { return }
                SwiftEntryKit.dismiss {
                    self.steps.accept(MyStatusSteps.exposurePopup(infectedDates: infectedDates))
                }
            })
        
        return Output(
            disposable: Disposables.create([
                binding,
                isInfectedBinding,
                checkExposureBinding
            ])
        )
    }
    
}

extension MyStatusViewModel {
    struct Input {
        let tableView: UITableView
    }
    
    struct Output {
        let disposable: Disposable
    }
}

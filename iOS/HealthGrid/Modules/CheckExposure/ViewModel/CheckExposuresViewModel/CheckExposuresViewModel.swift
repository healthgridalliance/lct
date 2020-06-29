import Foundation
import RxFlow
import RxSwift
import RxCocoa
import RxDataSources

public final class CheckExposuresViewModel: AppStepper {

    private var tableViewDataSource: RxTableViewSectionedReloadDataSource<ExposureSection>?
    private static let ReuseIdenfier = String(describing:  CheckExposureTableViewCell.self)
    private let sections: BehaviorSubject<[ExposureSection]> = BehaviorSubject(value: [])
    private var tableViewDelegate: CheckExposuresTableViewDelegate?
    
    override init() {
        super.init()
        initRxDataSource()
    }
    
    private func initRxDataSource() {
        tableViewDelegate = CheckExposuresTableViewDelegate()
        tableViewDataSource = RxTableViewSectionedReloadDataSource(configureCell: { [weak self] (_, tv, idx, item) in
            guard let self = self else { return UITableViewCell(frame: .zero) }
            let cell = tv.dequeueReusableCell(withIdentifier: CheckExposuresViewModel.ReuseIdenfier, for: idx) as! CheckExposureTableViewCell
            let output = cell.configure(item.date)
            if let lastRow = try? self.sections.value()[idx.section].items.count - 1 {
                cell.bottomSeparator.isHidden = idx.row != lastRow
            }
            self.handleSettingsCellOutput(output).disposed(by: cell.disposeBag)
            return cell
        }, titleForHeaderInSection: { [weak self] (_, idx) -> String? in
            guard let self = self else { return nil }
            return try? self.sections.value()[idx].title
        })
    }
    
    private func setupSections(with dates: [String]) {
        var items: [ExposureCellItem] = []
        dates.forEach({items.append(ExposureCellItem(date: $0))})
        sections.onNext([.exposures(items: items, title: "exposures_section_title".localized)])
    }
    
    private func handleSettingsCellOutput(_ output: CheckExposureCellViewModel.Output) -> Disposable {
        return Disposables.create([])
    }
    
    func bind(input: Input) -> Output {
        setupSections(with: input.dates)
        input.tableView.register(CheckExposureTableViewCell.self, forCellReuseIdentifier: CheckExposuresViewModel.ReuseIdenfier)
        
        let tableViewDelegateBinding = input.tableView.rx.setDelegate(tableViewDelegate!)
        let binding = sections.bind(to: input.tableView.rx.items(dataSource: self.tableViewDataSource!))
        let menuEventBinding = input.menuEvent.drive(onNext: { [weak self] in
            guard let self = self else { return }
            self.steps.accept(CheckExposureSteps.close)
        })
        let backEventBinding = input.backEvent.drive(onNext: { [weak self] in
            guard let self = self else { return }
            self.steps.accept(CheckExposureSteps.back)
        })
        
        return Output(
            disposable: Disposables.create([
                tableViewDelegateBinding,
                binding,
                menuEventBinding,
                backEventBinding
            ])
        )
    }
}

extension CheckExposuresViewModel {
    struct Input {
        let tableView: UITableView
        let backEvent: Driver<Void>
        let menuEvent: Driver<Void>
        let dates: [String]
    }
    
    struct Output {
        let disposable: Disposable
    }
}

struct ExposureCellItem {
    var date: String
}

enum ExposureSection {
    case exposures(items: [Item], title: String)
}

extension ExposureSection: SectionModelType {
    var items: [ExposureCellItem] {
        switch self {
        case .exposures(let items, _): return items
        }
    }
    
    var title: String {
       switch self {
       case .exposures(_ , let title): return title
        }
    }
    
    typealias Item = ExposureCellItem
    
    init(original: ExposureSection, items: [Item]) {
        switch original {
        case .exposures(items: _, let title):
            self = .exposures(items: items, title: title)
        }
    }
}

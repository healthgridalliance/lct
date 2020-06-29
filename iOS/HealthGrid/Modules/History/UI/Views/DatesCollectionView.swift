import Foundation
import UIKit
import RxCocoa
import RxSwift

final class DateCollectionView: UICollectionView, HasDisposeBag {
    
    private let selectedDate = BehaviorRelay<Date>(value: Date())
    private var initialDate: Date? = nil
    
    private var items = [DateCollectionItem]()
    private var lastSavedIndexPath = IndexPath(item: 0, section: 0)
        
    let fontsLayout: UICollectionViewFlowLayout = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.sectionInset = .zero
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        layout.itemSize = CGSize(width: 35, height: 44)
        return layout
    }()
    
    required init() {
        super.init(frame: CGRect.zero, collectionViewLayout: self.fontsLayout)
        self.backgroundColor = .clear
        
        self.register(DateCell.self, forCellWithReuseIdentifier: String(describing: DateCell.self))
        
        self.dataSource = self
        self.delegate = self
        
        self.showsHorizontalScrollIndicator = false
        self.showsVerticalScrollIndicator = false
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configureCollectionViewDataSource(with data: [Date]?) {
        guard let data = data else { return }
        self.items = data.map({DateCollectionItem(value: .date($0))})
        reloadData()
    }
    
    private func setDefaultDate() {
        guard !items.isEmpty else { return }
        var defaultItem: Int = 0
        if let initialDate = initialDate, let item = items.firstIndex(where: { $0.value.date.day == initialDate.day }) {
            defaultItem = item
        } else if let item = items.firstIndex(where: { $0.value.date.day  == Date().day }) {
            defaultItem = item
        }
        lastSavedIndexPath = IndexPath(item: defaultItem, section: 0)
        scrollToSelectedDate(animated: true, delay: 0.3)
    }
    
    private func isValid(date: Date) -> Bool {
        guard let initialDate = initialDate else { return false }
        let calendar = Calendar.deviceCalendar
        let date1 = calendar.startOfDay(for: date)
        let date2 = calendar.startOfDay(for: initialDate)
        guard let days = calendar.dateComponents([.day], from: date1, to: date2).day else { return false }
        return days <= 14
    }
    
    // MARK: - Public functions
    
    func configure(_ input: DatesCollectionViewModel.Input) -> DatesCollectionViewModel.Output {
        let datesBinding = input.dates.drive(onNext: { [weak self] dates in
            guard let self = self else { return }
            self.configureCollectionViewDataSource(with: dates)
        })
        let initialDateBinding = input.initialDate.drive(onNext: { [weak self] date in
            guard let self = self else { return }
            self.initialDate = date
        })
        let setDefaultSliderBinding = input.setDefaultSlider.drive(onNext: { [weak self] _ in
            guard let self = self else { return }
            self.setDefaultDate()
        })

        return DatesCollectionViewModel.Output(
            dateEvent: selectedDate,
            disposable: Disposables.create(
                datesBinding,
                initialDateBinding,
                setDefaultSliderBinding
            )
        )
    }
    
}

extension DateCollectionView: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return items.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let item = items[indexPath.item]
        switch item.value {
        case .date(let value):
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: DateCell.self), for: indexPath) as? DateCell else {
                return UICollectionViewCell()
            }
            cell.configure(with: value)
            cell.contentView.alpha = isValid(date: value) ? 1 : 0.3
            return cell
        }
    }
    
}

extension DateCollectionView: UIScrollViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        let item = items[indexPath.item]
        switch item.value {
        case .date(let value):
            if !isValid(date: value) {
                scrollToSelectedDate(animated: true)
            }
            return isValid(date: value)
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        scrollToLastVisibleRow()
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate {
            scrollToLastVisibleRow()
        }
    }
    
}

extension DateCollectionView: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let item = items[indexPath.item]
        switch item.value {
        case .date(let value):
            selectedDate.accept(value)
            lastSavedIndexPath = indexPath
            scrollToSelectedDate(animated: true)
        }
    }
    
}

extension DateCollectionView {
    
    func calculateLastNormalVisibleRow() -> Int? {
        guard let lastIndexPath = self.indexPathsForVisibleItems.sorted().last,
            let lastCell = cellForItem(at: lastIndexPath) else { return nil }
        if bounds.origin.x + bounds.size.width < lastCell.frame.maxX - 17.5 {
            return lastIndexPath.item - 1
        } else {
            return lastIndexPath.item
        }
    }
    
    func scrollToLastVisibleRow() {
        guard let lastRow = calculateLastNormalVisibleRow() else { return }
        let lastIndexPath = IndexPath(item: lastRow, section: 0)
        let item = items[lastIndexPath.item]
        switch item.value {
        case .date(let value):
            if isValid(date: value) {
                selectedDate.accept(value)
                self.lastSavedIndexPath = lastIndexPath
            }
        }
        scrollToSelectedDate(animated: true)
    }
    
    func scrollToSelectedDate(animated: Bool = true, delay: Double = 0.1) {
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
            self.scrollToItem(at: self.lastSavedIndexPath, at: .right, animated: animated)
            self.selectItem(at: self.lastSavedIndexPath, animated: animated, scrollPosition: .right)
        }
    }

}

public struct DatesCollectionViewModel: Equatable {
    
    public struct Input {
        public var initialDate: Driver<Date>
        public var dates: Driver<[Date]>
        public var setDefaultSlider: Driver<Void>
    }
    
    public struct Output {
        public var dateEvent: BehaviorRelay<Date>
        public var disposable: Disposable
    }
}

// MARK: - FontItem

struct DateCollectionItem: Equatable {
    typealias Identity = String
    
    var identity: String {
        return value.title
    }
    
    var value: DateCollectionItemType
    
    static func == (lhs: DateCollectionItem, rhs: DateCollectionItem) -> Bool {
        switch (lhs.value, rhs.value) {
        case (let .date(old), let .date(new)):
            return old == new
        }
    }
}

enum DateCollectionItemType {
    case date(_ value: Date)
    
    var title: String {
        switch self {
        case let .date(value): return DateFormatter.dateFormatter.string(from: value)
        }
    }
    
    var date: Date {
        switch self {
        case let .date(value): return value
        }
    }
}

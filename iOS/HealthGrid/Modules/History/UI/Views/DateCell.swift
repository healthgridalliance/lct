import Foundation
import UIKit
import Stevia

final class DateCell: UICollectionViewCell {
        
    private let dayLabel = UILabel()
    private let dateLabel = UILabel()
    
    override var isSelected: Bool {
        didSet {
            dateLabel.textColor = isSelected ? .white : .main
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setup() {
        contentView.sv(dayLabel, dateLabel)
            .layout (8,
                     dayLabel.height(13).centerHorizontally(),
                     2,
                     dateLabel.height(13).centerHorizontally(),
                     8)
        contentView.style {
            $0.backgroundColor = .clear
        }
        dayLabel.style {
            $0.textAlignment = .center
            $0.textColor = UIColor.main.withAlphaComponent(0.3)
            $0.font = Typography.extraSmall(.regular).font()
        }
        dateLabel.style {
            $0.textAlignment = .center
            $0.textColor = UIColor.main
            $0.font = Typography.extraSmall(.bold).font()
        }
    }
    
    public func configure(with date: Date) {
        let calendar = Calendar.deviceCalendar
        let day = calendar.component(.day, from: date)
        let weekday = calendar.component(.weekday, from: date)
        dayLabel.text = calendar.shorterWeekdaySymbols[weekday - 1].uppercased()
        dateLabel.text = "\(day)"
    }
    
}

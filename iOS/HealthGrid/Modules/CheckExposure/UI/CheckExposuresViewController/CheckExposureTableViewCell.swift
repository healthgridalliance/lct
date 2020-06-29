import UIKit
import Stevia
import RxSwift
import RxCocoa

class CheckExposureTableViewCell: UITableViewCell, HasDisposeBag {
    
    private let titleLabel = UILabel()
    private let subtitleLabel = UILabel()
    private let topSeparator = UIView()
    public let bottomSeparator = UIView()
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        setup()
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        setup()
    }

    private func setup() {
        style {
            $0.backgroundColor = .clear
            $0.selectionStyle = .none
        }
        
        sv(topSeparator, titleLabel, subtitleLabel, bottomSeparator)
            .layout(0,
                    |-0-topSeparator.height(0.5)-0-|,
                    8.5,
                    |-16-titleLabel.height(24)-16-|,
                    -2,
                    |-16-subtitleLabel.height(22)-16-|,
                    6.5,
                    |-0-bottomSeparator-0-|,
                    0)
        [topSeparator, bottomSeparator].forEach({$0.backgroundColor = .cellSeparator})
        
        titleLabel.style {
            $0.font = Typography.normal(.regular).font()
            $0.textColor = .main
            $0.text = "exposure_item_title".localized
        }
        subtitleLabel.style {
            $0.font = Typography.normal(.regular).font()
            $0.textColor = .legendRed
        }
    }
    
    func configure(_ date: String) -> CheckExposureCellViewModel.Output {
        subtitleLabel.style {
            $0.text = date
        }
        
        return CheckExposureCellViewModel.Output(
            disposable: Disposables.create([])
        )
    }
}

public struct CheckExposureCellViewModel: Equatable {
    
    public struct Input {
    }
    
    public struct Output {
        public var disposable: Disposable
    }
    
}

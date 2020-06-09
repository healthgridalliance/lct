import UIKit
import Stevia
import RxSwift
import RxCocoa

final class DatesSlider: UIView {
    
    private let contentView = UIView()
    private let backgroundView = UIView()
    private let pickDateButton = StyledButton()
    private let collectionView = DateCollectionView()
    private let selectionView = UIView()
    
    private let dates = BehaviorRelay<[Date]>(value: Date().lastTwoWeeks())
      
    init() {
        super.init(frame: .zero)
        
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        updateCornerRadius()
        updateLayerProperties()
    }
    
    private func updateCornerRadius() {
        selectionView.style {
            $0.layer.cornerRadius = 20
        }
        backgroundView.style {
            $0.layer.cornerRadius = 24
            $0.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMaxXMaxYCorner]
        }
    }
    
    private func updateLayerProperties() {
        layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.25).cgColor
        layer.shadowOffset = CGSize(width: 0, height: 3)
        layer.shadowOpacity = 1.0
        layer.shadowRadius = 5.0
        layer.masksToBounds = false
    }
    
    private func setupUI() {
        sv(contentView)
        contentView.style {
            $0.fillContainer()
        }
        
        contentView.sv(backgroundView, selectionView, collectionView, pickDateButton)
        contentView.layout (6,
                     |-0-backgroundView-0-|,
                     6)
        contentView.layout (6,
                     |-0-collectionView-10-pickDateButton-10-|,
                     6)
        collectionView.style {
            $0.contentInset = UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 0)
        }
        selectionView.style {
            $0.Top == contentView.Top
            $0.Bottom == contentView.Bottom
            $0.Trailing == pickDateButton.Leading - 7.5
            $0.width(40)
            $0.backgroundColor = .buttonBlue
        }
        backgroundView.style {
            $0.backgroundColor = .background
        }
        pickDateButton.style {
            $0.Top == backgroundView.Top
            $0.Bottom == backgroundView.Bottom
            $0.buttonStyle = .clear(title: "history_pick_button".localized)
        }
    }
    
    public func configure(_ input: DatesSliderViewModel.Input) -> DatesSliderViewModel.Output {
        let datesCollectionOutput = collectionView.configure(
            DatesCollectionViewModel.Input(
                initialDate: input.initialDate,
                dates: dates.asDriver(),
                setDefaultSlider: input.setDefaultSlider
            )
        )
        
        return DatesSliderViewModel.Output(
            dateEvent: datesCollectionOutput.dateEvent,
            tipEvent: pickDateButton.rx.tap.asDriver(),
            disposable: datesCollectionOutput.disposable
        )
    }
    
}

public struct DatesSliderViewModel: Equatable {
    
    public struct Input {
        public var initialDate: Driver<Date>
        public var setDefaultSlider: Driver<Void>
    }
    
    public struct Output {
        public var dateEvent: BehaviorRelay<Date>
        public var tipEvent: Driver<Void>
        public var disposable: Disposable
    }
}

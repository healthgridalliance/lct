import UIKit
import Stevia
import RxSwift
import RxCocoa

class SettingsTableViewCell: UITableViewCell, HasDisposeBag {
    
    public let actionButton = SettingsButton()
    private var selectionType = PublishSubject<SettingsCellType>()

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
        
        sv(actionButton)
            .layout(8,
                    |-16-actionButton.height(52)-16-|,
                    8)
    }
    
    func configure(_ input: SettingsCellViewModel.Input, type: SettingsCellType) -> SettingsCellViewModel.Output {
        actionButton.style {
            $0.titleLabel?.font = Typography.normal(.regular).font()
            $0.setTitle(type.title, for: UIControl.State())
        }
        
        let actionEventBinding = actionButton.rx.tap.subscribe(onNext: { [weak self, type] in
            guard let self = self else { return }
            self.selectionType.onNext(type)
        })
        
        let selectionEventBinding = input.isSelected?.bind(to: actionButton.rx.isSelected)
        
        return SettingsCellViewModel.Output(
            actionEvent: selectionType,
            disposable: Disposables.create([
                selectionEventBinding,
                actionEventBinding
                ].compactMap({$0}))
        )
    }
}

public struct SettingsCellViewModel: Equatable {
    
    public struct Input {
        public var isSelected: BehaviorRelay<Bool>?
    }
    
    public struct Output {
        public var actionEvent: PublishSubject<SettingsCellType>
        public var disposable: Disposable
    }
    
}

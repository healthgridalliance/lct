import UIKit
import Stevia
import SwiftEntryKit

public class DatesTipPopup: UIView {

    private let contentView = UIView(frame: .zero)
    private let titleLabel = UILabel(frame: .zero)
    
    public override init(frame: CGRect) {
        super.init(frame: .zero)
        
        setup()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setup() {
        sv(contentView)
            .layout(0,
                    |-(>=0)-contentView-0-|,
                    0)
        contentView.sv(titleLabel)
        titleLabel.fillContainer(20)
        
        contentView.style {
            $0.backgroundColor = .white
            $0.layer.cornerRadius = 16
        }
        titleLabel.style {
            $0.font = Typography.normal(.regular).font()
            $0.textColor = UIColor.main
            $0.text = "history_popup".localized
            $0.textAlignment = .center
            $0.numberOfLines = 0
        }
    }
    
}

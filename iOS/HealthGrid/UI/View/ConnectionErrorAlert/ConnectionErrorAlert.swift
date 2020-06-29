import UIKit
import Stevia
import SwiftEntryKit

public class ConnectionErrorAlert: UIView {
    
    public static let entryName = "ConnectionErrorAlert"

    private let contentView = UIView()
    private let titleLabel = UILabel()
    
    public override init(frame: CGRect) {
        super.init(frame: .zero)
        
        setup()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setup() {
        let guide = UIApplication.shared.keyWindow!.safeAreaInsets
        sv(contentView)
        contentView.sv(titleLabel)
        contentView.fillContainer()
        contentView.layout (
            guide.top,
            |-13-titleLabel-13-|,
            13
        )
        
        titleLabel.style {
            $0.font = Typography.small(.regular).font()
            $0.textColor = .white
            $0.text = "connection_error_message".localized
            $0.numberOfLines = 0
            $0.textAlignment = .center
        }
    }
    
}

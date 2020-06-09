import UIKit
import Stevia
import SwiftEntryKit

public class MapLegendPopup: UIView {

    private let contentView = UIView(frame: .zero)
    private let closeButton = StyledButton()
    private let titleLabel = UILabel(frame: .zero)
    private let legendStackView = UIStackView()
    
    public override init(frame: CGRect) {
        super.init(frame: .zero)
        
        setup()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setup() {
        sv(contentView)
        contentView.sv(closeButton, titleLabel, legendStackView)
        contentView.layout (
            23,
            |-24-titleLabel.height(33)-24-closeButton.size(44)-9-|,
            35,
            |-24-legendStackView-24-|,
            34
        )
        contentView.fillContainer()
        
        titleLabel.style {
            $0.font = Typography.extraLarge(.bold).font()
            $0.textColor = UIColor.main
            $0.text = "map_legend_title".localized
        }
        
        closeButton.style {
            $0.buttonStyle = .assetsIcon(name: "ic_close", colour: nil, dimension: 44)
            $0.buttonHandler = {
                SwiftEntryKit.dismiss()
            }
        }
        
        legendStackView.style {
            $0.spacing = 16.0
            $0.axis = .vertical
        }

        [MapLegend(type: .healthy),
         MapLegend(type: .notWell),
         MapLegend(type: .ill)]
            .forEach {
                legendStackView.addArrangedSubview($0)
        }
    }
    
}

enum MapLegendType {
    case healthy
    case notWell
    case ill
    
    var color: UIColor {
        switch self {
        case .healthy: return UIColor.legendGreen
        case .notWell: return UIColor.legendYellow
        case .ill: return UIColor.legendRed
        }
    }
    
    var title: String {
        switch self {
        case .healthy: return "map_legend_healthy".localized
        case .notWell: return "map_legend_not_well".localized
        case .ill: return "map_legend_ill".localized
        }
    }
}

class MapLegend: UIView {
    
    private let contentView = UIView(frame: .zero)
    private let dotView = UIView(frame: .zero)
    private let titleLabel = UILabel(frame: .zero)
    
    init(type: MapLegendType) {
        super.init(frame: .zero)
        setup(with: type)
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setup(with type: MapLegendType) {
        sv(contentView)
        contentView.sv(dotView, titleLabel)
        
        dotView.style {
            $0.size(14)
            $0.layer.cornerRadius = 7
            $0.Leading == contentView.Leading
            $0.centerVertically()
            $0.backgroundColor = type.color
        }
        titleLabel.style {
            $0.height(>=23)
            $0.font = Typography.large(.regular).font()
            $0.textColor = UIColor.main
            $0.Leading == dotView.Trailing + 16
            $0.Trailing == contentView.Trailing
            $0.Top == contentView.Top
            $0.Bottom == contentView.Bottom
            $0.numberOfLines = 0
            $0.text = type.title
        }
        contentView.fillContainer()
    }
    
}

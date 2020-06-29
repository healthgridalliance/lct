import UIKit
import Stevia
import RxSwift
import RxCocoa

final class MapTabBarView: UIView, HasDisposeBag {
    
    private let selectedTab = PublishSubject<MapTabItem>()
    private let tabs = [MapTabItem.diagnosis, MapTabItem.exposure, MapTabItem.configuration]
    private var tabItems: [MapTabBarItem] = []
    private let toolbar = UIStackView()
    
    init() {
        super.init(frame: .zero)
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setup() {
        tabItems = tabs.enumerated().map { (offset, type) -> MapTabBarItem in
            let item = type.tabItem
            item.tag = offset
            item.button.rx.tap.mapTo(type).bind(to: self.selectedTab).disposed(by: disposeBag)
            return item
        }
        
        sv(toolbar)
        toolbar.style {
            $0.fillContainer()
        }
        tabItems.forEach({toolbar.addArrangedSubview($0)})
        
        toolbar.style {
            $0.axis = .horizontal
            $0.distribution = .fillEqually
            $0.alignment = .bottom
        }
    }
    
    public func configure() -> MapTabBarView.Output {
        return MapTabBarView.Output(
            tabEvent: selectedTab,
            disposable: Disposables.create()
        )
    }
    
}

extension MapTabBarView {
    
    struct Output {
        var tabEvent: PublishSubject<MapTabItem>
        let disposable: Disposable
    }
}

enum MapTabItem {
    case diagnosis, exposure, configuration
    
    var title: String {
        switch self {
        case .diagnosis: return "tab_bar_diagnosis_button".localized
        case .exposure: return "tab_bar_exposure_button".localized
        case .configuration: return "tab_bar_config_button".localized
        }
    }
    
    var icon: UIImage? {
        switch self {
        case .diagnosis: return UIImage(named: "ic_diagnosis")
        case .exposure: return UIImage(named: "ic_exposure")
        case .configuration: return UIImage(named: "ic_config")
        }
    }
    
    var tabItem: MapTabBarItem {
        return MapTabBarItem(type: self)
    }
}

final class MapTabBarItem: UIView {
    
    private let title = UILabel()
    private let image = UIImageView()
    public let button = StyledButton()
    
    private let type: MapTabItem
    
    init(type: MapTabItem) {
        self.type = type
        super.init(frame: .zero)
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        guard type == .exposure else { return }
        updateMask()
    }

    private func updateMask() {
        let path = UIBezierPath()
        let center = CGPoint(x: bounds.midX, y: 30)
        path.addArc(withCenter: center, radius: 30, startAngle: .pi, endAngle: 0, clockwise: true)
        path.addLine(to: CGPoint(x: bounds.maxX, y: 30))
        path.addLine(to: CGPoint(x: bounds.maxX, y: bounds.maxY))
        path.addLine(to: CGPoint(x: bounds.minX, y: bounds.maxY))
        path.addLine(to: CGPoint(x: bounds.minX, y: 30))
        path.close()

        let mask = CAShapeLayer()
        mask.path = path.cgPath

        layer.mask = mask
    }
    
    public func setup() {
        style {
            $0.backgroundColor = .background
            $0.height(type == .exposure ? 80 : 50)
        }
        sv(title, image, button)
            .layout(8,
                    image.size(type == .exposure ? 44 : 24).centerHorizontally(),
                    type == .exposure ? 10 : 0,
                    |-0-title.height(18)-0-|,
                    0)
        button.style {
            $0.fillContainer()
        }
        title.style {
            $0.textColor = .buttonBlue
            $0.text = type.title
            $0.font = Typography.extraSmall(.regular).font()
            $0.textAlignment = .center
        }
        image.style {
            $0.image = type.icon
        }
    }
    
}

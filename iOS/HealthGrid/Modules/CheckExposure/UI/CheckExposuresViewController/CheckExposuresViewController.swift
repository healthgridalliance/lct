import Foundation
import UIKit
import Stevia
import RxSwift
import RxCocoa

final class CheckExposuresViewController: UIViewController {

    private let tableView = UITableView()
    private let backButton = BackButton()
    private let exposuresTitle = UILabel()
    private let exposuresLogo = UIImageView()
    private let menuButton = StyledButton()
    
    private var viewModel: CheckExposuresViewModel?
    
    // MARK: - Lifecycle
       
    override public func viewDidLoad() {
        super.viewDidLoad()
                   
        setup()
    }
       
    // MARK: - Private functions
       
    private func setup() {
        setupUI()
        setupStyle()
    }
       
    private func setupUI() {
        let guide = UIApplication.shared.keyWindow!.safeAreaInsets
        view.sv(exposuresLogo, tableView, backButton, exposuresTitle, menuButton)
            .layout(guide.top + 22,
                    |-8-backButton.width(76).height(34),
                    8,
                    |-0-tableView-0-|,
                    16,
                    |-16-menuButton.height(50)-16-|,
                    guide.bottom + 16)
        exposuresTitle.style {
            $0.Top == guide.top + 22
            $0.centerHorizontally()
        }
        exposuresLogo.style {
            $0.size(230)
            $0.centerHorizontally()
            $0.Bottom == menuButton.Top - 44
        }
    }
       
    private func setupStyle() {
        view.style {
            $0.backgroundColor = .white
        }
        tableView.style {
            $0.backgroundColor = .clear
            $0.separatorStyle = .none
            $0.contentInsetAdjustmentBehavior = .never
        }
        exposuresTitle.style {
            $0.text = "exposures_title".localized
            $0.textColor = Palette.main.color()
            $0.font = Typography.extraLarge(.bold).font()
        }
        exposuresLogo.style {
            $0.image = UIImage(named: "check_exposure_logo")
            $0.contentMode = .scaleAspectFill
        }
        menuButton.style {
            $0.buttonStyle = .blue(title: "exposure_menu_button".localized)
        }
    }
       
    // MARK: - Public functions
       
    func set(viewModel: CheckExposuresViewModel, dates: [String]) {
        self.viewModel = viewModel
    
        let output = viewModel.bind(input:
            CheckExposuresViewModel.Input(
                tableView: tableView,
                backEvent: backButton.rx.tap.asDriver(),
                menuEvent: menuButton.rx.tap.asDriver(),
                dates: dates)
        )
           
        disposeBag.insert(
            output.disposable
        )
        output.disposable.disposed(by: self.disposeBag)
    }
    
}

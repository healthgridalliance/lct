import UIKit
import Stevia
import RxSwift
import RxCocoa
import SwiftEntryKit

final class MyStatusViewController: UIViewController {

    private let titleLabel = UILabel()
    private let infoLabel = UILabel()
    private let closeButton = StyledButton()
    private let tableView = UITableView()
    
    private var viewModel: MyStatusViewModel?
            
    // MARK: - Lifecycle
        
    override public func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
        
    // MARK: - Private functions
        
    private func setup() {
        setupUI()
        setupStyle()
        setupBinding()
    }
        
    private func setupUI() {
        let guide = UIApplication.shared.keyWindow!.safeAreaInsets
        view.sv(titleLabel, infoLabel, closeButton, tableView)
            .layout (20,
                     |-16-titleLabel.height(33)-16-closeButton.size(44)-9-|,
                     27,
                     |-16-infoLabel-16-|,
                     16,
                     |-0-tableView.height(272)-0-|,
                     guide.bottom + 16)
    }
        
    private func setupStyle() {
        view.style {
            $0.backgroundColor = .clear
        }
        titleLabel.style {
            $0.font = Typography.extraLarge(.bold).font()
            $0.text = "status_title".localized
        }
        infoLabel.style {
            $0.font = Typography.normal(.regular).font()
            $0.text = "status_info".localized
            $0.numberOfLines = 0
        }
        closeButton.style {
            $0.buttonStyle = .assetsIcon(name: "ic_close", colour: nil, dimension: 44)
            $0.buttonHandler = {
                SwiftEntryKit.dismiss()
            }
        }
        tableView.style {
            $0.bounces = false
            $0.backgroundColor = .clear
            $0.rowHeight = UITableView.automaticDimension
            $0.estimatedRowHeight = 44
            $0.separatorStyle = .none
            $0.contentInsetAdjustmentBehavior = .never
        }
    }
        
    private func setupBinding() {
    }
        
    // MARK: - Public functions
        
    func set(viewModel: MyStatusViewModel) {
        self.viewModel = viewModel
            
        let output = viewModel.bind(input:
            MyStatusViewModel.Input(tableView: self.tableView)
        )
            
        disposeBag.insert(
            output.disposable
        )
        output.disposable.disposed(by: self.disposeBag)
    }
    
}

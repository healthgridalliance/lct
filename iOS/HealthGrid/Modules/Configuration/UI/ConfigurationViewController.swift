import UIKit
import Stevia
import RxSwift
import RxCocoa
import SwiftEntryKit

final class ConfigurationViewController: UIViewController {

    private let titleLabel = UILabel()
    private let closeButton = StyledButton()
    private let tableView = UITableView()
    
    private var viewModel: ConfigurationViewModel?
            
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
        view.sv(titleLabel, closeButton, tableView)
            .layout (20,
                     |-16-titleLabel.height(33)-16-closeButton.size(44)-9-|,
                     12,
                     |-0-tableView.height(408)-0-|,
                     guide.bottom + 16)
    }
        
    private func setupStyle() {
        view.style {
            $0.backgroundColor = .clear
        }
        titleLabel.style {
            $0.font = Typography.extraLarge(.bold).font()
            $0.text = "configuration_title".localized
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
            $0.allowsSelection = false
        }
    }
        
    private func setupBinding() {
    }
        
    // MARK: - Public functions
        
    func set(viewModel: ConfigurationViewModel) {
        self.viewModel = viewModel
            
        let output = viewModel.bind(input:
            ConfigurationViewModel.Input(tableView: self.tableView)
        )
            
        disposeBag.insert(
            output.disposable
        )
        output.disposable.disposed(by: self.disposeBag)
    }
    
}

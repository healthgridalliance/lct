import Foundation
import UIKit

class CheckExposuresTableViewDelegate: NSObject, UITableViewDelegate {

    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 38
    }
 
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        guard let header = view as? UITableViewHeaderFooterView else { return }
        header.textLabel?.textColor = UIColor.main.withAlphaComponent(0.5)
        header.textLabel?.font = Typography.normal(.regular).font()
        header.contentView.backgroundColor = .white
    }
    
}

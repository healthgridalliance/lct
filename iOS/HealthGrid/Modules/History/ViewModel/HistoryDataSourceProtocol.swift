import Foundation
import RxCocoa
import RxSwift

public protocol HistoryDataSourceProtocol: class {
    func getHistory() -> Observable<LocationResponse>
}

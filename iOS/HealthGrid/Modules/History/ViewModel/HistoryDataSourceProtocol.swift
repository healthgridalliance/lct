import Foundation
import RxCocoa
import RxSwift

public protocol HistoryDataSourceProtocol: class {
    func getHistory(date: Date) -> Observable<LocationResponse>
}

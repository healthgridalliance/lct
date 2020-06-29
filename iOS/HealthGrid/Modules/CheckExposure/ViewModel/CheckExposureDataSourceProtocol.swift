import Foundation
import RxCocoa
import RxSwift

public protocol CheckExposureDataSourceProtocol: class {
    func checkExposure(date: Date) -> Observable<LocationResponse>
}

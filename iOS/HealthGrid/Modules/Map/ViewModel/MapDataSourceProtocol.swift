import Foundation
import RxCocoa
import RxSwift

public protocol MapDataSourceProtocol: class {
    func registerApp() -> Observable<BaseResponse>
    func getLocationsData() -> Observable<LocationResponse>
    func deleteLocationsData() -> Observable<BaseResponse>
}

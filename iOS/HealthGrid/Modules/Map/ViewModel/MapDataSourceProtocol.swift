import Foundation
import RxCocoa
import RxSwift

public protocol MapDataSourceProtocol: class {
    func getInitialParameters() -> Observable<InitialResponse>
    func getLocationsData() -> Observable<LocationResponse>
    func deleteLocationsData() -> Observable<BaseResponse>
    func checkExposure(date: Date) -> Observable<LocationResponse>
}

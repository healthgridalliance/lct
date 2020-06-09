import Foundation
import RxCocoa
import RxSwift

public protocol MyStatusDataSourceProtocol: class {
    func sendStatus(_ status: Bool) -> Observable<BaseResponse>
    func sendHistory(_ locations: [Location]) -> Observable<BaseResponse>
    func checkExposure() -> Observable<LocationResponse>
}

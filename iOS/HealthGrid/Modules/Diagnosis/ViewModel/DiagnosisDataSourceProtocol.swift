import Foundation
import RxCocoa
import RxSwift

public protocol DiagnosisDataSourceProtocol: class {
    func sendHistory(_ locations: [Location], id: String) -> Observable<BaseResponse>
}

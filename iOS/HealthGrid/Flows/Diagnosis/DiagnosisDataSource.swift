import Foundation
import RxSwift
import RxCocoa
import SwiftyUserDefaults

final class DiagnosisDataSource {
    
    private let apiClient = APIClient()
    
}

extension DiagnosisDataSource: DiagnosisDataSourceProtocol {
    
    func sendHistory(_ locations: [Location], id: String) -> Observable<BaseResponse> {
        let request = LocationHistoryRequest.sendLocations(data: locations, id: id)
        return apiClient
            .send(apiRequest: request)
            .do(onNext: { _ in
                Defaults[\.testUniqueId] = id
            })
            .observeOn(MainScheduler.instance)
            .share(replay: 1)
    }
    
}

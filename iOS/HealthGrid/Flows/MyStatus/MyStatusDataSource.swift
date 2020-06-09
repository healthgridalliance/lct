import Foundation
import RxSwift
import RxCocoa

final class MyStatusDataSource {
    
    private let apiClient = APIClient()
    
}

extension MyStatusDataSource: MyStatusDataSourceProtocol {
    
    func sendStatus(_ status: Bool) -> Observable<BaseResponse> {
        let request = MyStatusRequest.infected(status: status)
        return apiClient
            .send(apiRequest: request)
            .observeOn(MainScheduler.instance)
            .share(replay: 1)
    }
    
    func sendHistory(_ locations: [Location]) -> Observable<BaseResponse> {
        let request = MyStatusRequest.sendLocations(data: locations)
        return apiClient
            .send(apiRequest: request)
            .observeOn(MainScheduler.instance)
            .share(replay: 1)
    }
    
    func checkExposure() -> Observable<LocationResponse> {
        let request = MyStatusRequest.checkExposure
        return apiClient
            .send(apiRequest: request)
            .observeOn(MainScheduler.instance)
            .share(replay: 1)
    }
    
}

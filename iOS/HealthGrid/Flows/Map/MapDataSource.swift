import Foundation
import RxSwift
import RxCocoa

final class MapDataSource {
    
    private let apiClient = APIClient()
    
}

extension MapDataSource: MapDataSourceProtocol {
    
    func registerApp() -> Observable<BaseResponse> {
        let request = MapRequest.registerApp
        return apiClient
            .send(apiRequest: request)
            .observeOn(MainScheduler.instance)
            .share(replay: 1)
    }
    
    func getLocationsData() -> Observable<LocationResponse> {
        let request = MapRequest.getData
        return apiClient
            .send(apiRequest: request)
            .observeOn(MainScheduler.instance)
            .share(replay: 1)
    }
    
    func deleteLocationsData() -> Observable<BaseResponse> {
        let request = MapRequest.deleteData
        return apiClient
            .send(apiRequest: request)
            .observeOn(MainScheduler.instance)
            .share(replay: 1)
    }
    
}

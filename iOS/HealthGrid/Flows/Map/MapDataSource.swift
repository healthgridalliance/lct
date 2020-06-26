import Foundation
import RxSwift
import RxCocoa

final class MapDataSource {
    
    private let apiClient = APIClient()
    
}

extension MapDataSource: MapDataSourceProtocol {
    
    func getInitialParameters() -> Observable<InitialResponse> {
        let request = InitialRequest.parameters
        return apiClient
            .send(apiRequest: request)
            .observeOn(MainScheduler.instance)
            .share(replay: 1)
    }
    
    func getLocationsData() -> Observable<LocationResponse> {
        let request = HeatZonesRequest.heatzone(date: Date())
        return apiClient
            .send(apiRequest: request)
            .observeOn(MainScheduler.instance)
            .share(replay: 1)
    }
    
    func deleteLocationsData() -> Observable<BaseResponse> {
        let request = LocationHistoryRequest.deleteLocations
        return apiClient
            .send(apiRequest: request)
            .observeOn(MainScheduler.instance)
            .share(replay: 1)
    }
    
    func checkExposure(date: Date) -> Observable<LocationResponse> {
        let request = HeatZonesRequest.heatzone(date: date)
        return apiClient
            .send(apiRequest: request)
            .observeOn(MainScheduler.instance)
            .share(replay: 1)
    }
    
}

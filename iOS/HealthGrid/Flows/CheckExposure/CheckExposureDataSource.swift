import Foundation
import RxSwift
import RxCocoa

final class CheckExposureDataSource {
    
    private let apiClient = APIClient()
    
}

extension CheckExposureDataSource: CheckExposureDataSourceProtocol {
    
    func checkExposure(date: Date) -> Observable<LocationResponse> {
        let request = HeatZonesRequest.heatzone(date: date)
        return apiClient
            .send(apiRequest: request)
            .observeOn(MainScheduler.instance)
            .share(replay: 1)
    }
    
}

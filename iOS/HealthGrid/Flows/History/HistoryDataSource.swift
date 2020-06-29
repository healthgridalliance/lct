import Foundation
import RxSwift
import RxCocoa

final class HistoryDataSource {
    
    private let apiClient = APIClient()
    
}

extension HistoryDataSource: HistoryDataSourceProtocol {
    
    func getHistory(date: Date) -> Observable<LocationResponse> {
        let request = HeatZonesRequest.heatzone(date: date)
        return apiClient
            .send(apiRequest: request)
            .observeOn(MainScheduler.instance)
            .share(replay: 1)
    }
    
}

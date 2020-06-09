import Foundation
import RxSwift
import RxCocoa

final class HistoryDataSource {
    
    private let apiClient = APIClient()
    
}

extension HistoryDataSource: HistoryDataSourceProtocol {
    
    func getHistory() -> Observable<LocationResponse> {
        let request = HistoryRequest.history
        return apiClient
            .send(apiRequest: request)
            .observeOn(MainScheduler.instance)
            .share(replay: 1)
    }
    
}

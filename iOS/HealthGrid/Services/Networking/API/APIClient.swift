import Foundation
import RxSwift
import SwiftEntryKit

enum ErrorType: Int {
    case requestConnectionError = -1009
    case approovConnectionError = 2
}

class APIClient {
    
    private let baseURL = URL(string: BaseURL.vAPI1.rawValue)!

    func send<T: Codable>(apiRequest: APIRequest) -> Observable<T> {
        return Observable<T>.create { [weak self] observer in
            guard let self = self else { return Disposables.create() }
            let request = apiRequest.request(with: self.baseURL)
            let task = ApproovURLSession(configuration: .default).dataTask(with: request) { (data, response, error) in
                if let error = error as NSError? {
                    switch ErrorType(rawValue: error.code) {
                    case .requestConnectionError,
                         .approovConnectionError:
                        self.showConnetionErrorAlert()
                    default: break
                    }
                } else {
                    do {
                        let model: T = try JSONDecoder().decode(T.self, from: data ?? Data())
                        print("==================================================")
                        print("Response: \(model)")
                        observer.onNext(model)
                    } catch let error {
                        print("==================================================")
                        print("Error: \(error)")
                    }
                }
                observer.onCompleted()
            }
            task.resume()
            
            return Disposables.create {
                task.cancel()
            }
        }
    }
}

extension APIClient {
    
    private func showConnetionErrorAlert() {
        DispatchQueue.main.async {
            guard !SwiftEntryKit.isCurrentlyDisplaying(entryNamed: ConnectionErrorAlert.entryName) else { return }
            let popup = ConnectionErrorAlert()
            SwiftEntryKit.display(entry: popup, using: EKAttributes.connectionErrorPopupDisplayAttributes)
        }
    }
    
}

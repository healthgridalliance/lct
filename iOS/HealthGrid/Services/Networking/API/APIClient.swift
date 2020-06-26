import Foundation
import RxSwift
import SwiftEntryKit
import ObjectMapper

enum ErrorType: Int {
    case requestConnectionError = -1009
    case approovConnectionError = 2
}

enum APIErrorDomain : String {
    case parseError
}

enum APIErrorCode : Int {
    case serializationError
    case modelParseError
}

class APIClient {
    
    private let baseURL = URL(string: BaseURL.vAPI1.rawValue)!

    func send<T: Mappable>(apiRequest: APIRequest) -> Observable<T> {
        return Observable<T>.create { [weak self] observer in
            guard let self = self else { return Disposables.create() }
            let request = apiRequest.request(with: self.baseURL)
            
            #if DEBUG
            print("==================================================")
            print("Request: \(request)")
            #endif
            
            let task = ApproovURLSession(configuration: .default).dataTask(with: request) { (data, response, error) in
                
                func send(error: Error) {
                    
                    #if DEBUG
                    print("==================================================")
                    print("Error: \(error)")
                    #endif
                    
//                    observer.onError(error)
                }
                
                if let error = error as NSError? {
                    switch ErrorType(rawValue: error.code) {
                    case .requestConnectionError,
                         .approovConnectionError:
                        self.showConnetionErrorAlert()
                    default: break
                    }
                    send(error: error)
                } else if let data = data {
                    do {
                        if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String : Any] {
                            
                            #if DEBUG
                            print("==================================================")
                            print("Response: \(json)")
                            #endif
                            
                            if let model: T = T(JSON: json) {
                                observer.onNext(model)
                            } else {
                                send(error: NSError(domain: APIErrorDomain.parseError.rawValue,
                                                    code: APIErrorCode.modelParseError.rawValue))
                            }
                        } else {
                            send(error: NSError(domain: APIErrorDomain.parseError.rawValue,
                                                code: APIErrorCode.serializationError.rawValue))
                        }
                    } catch let error {
                        send(error: error)
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

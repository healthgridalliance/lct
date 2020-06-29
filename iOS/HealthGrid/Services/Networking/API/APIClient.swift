import Foundation
import RxSwift
import SwiftEntryKit
import ObjectMapper

enum ErrorType: Int {
    case requestConnectionError = -1009
    case approovConnectionError = 2
}

enum APIErrorDomain: String {
    case parseError
    case responseError
}

enum APIErrorCode: Int {
    case unknown
    case serializationError
    case modelParseError
    case clientError
    case serverError
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
//                    self.showErrorAlert(with: error)
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
                    if let error = self.errorFromStatusCodeFromHTTPResponse(response as? HTTPURLResponse) {
                        send(error: error)
                    }
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
    
    private func showErrorAlert(with error: Error) {
        DispatchQueue.main.async {
            let alertController = UIAlertController(title: "error".localized,
                                                    message: error.localizedDescription,
                                                    preferredStyle: .alert)

            let cancelAction = UIAlertAction(title: "ok".localized, style: .default, handler: nil)
            alertController.addAction(cancelAction)
                    
            UIApplication.shared.windows.last?.rootViewController?.present(alertController, animated: true, completion: nil)
        }
    }
    
    public func errorFromStatusCodeFromHTTPResponse(_ response: HTTPURLResponse?) -> NSError? {
        guard let response = response else { return nil }
        
        let statusCode = response.statusCode
        
        let domain = APIErrorDomain.responseError
        var errorCode: APIErrorCode?
        var message = ""
        
        switch statusCode {
        case 200..<300: break
            
        case 400..<500:
            errorCode = .clientError
            message = "HTTP client error (status: \(statusCode))"
            
        case 500..<600:
            errorCode = .serverError
            message = "HTTP server error (status: \(statusCode))"
            
        default:
            errorCode = .unknown
            message = "Uncategorized connection error (status: \(statusCode))"
        }
        
        var error : NSError?
        if errorCode != nil {
            let technicalMessage = HTTPURLResponse.localizedString(forStatusCode: statusCode)
            
            error = NSError(
                domain: domain.rawValue,
                code: statusCode,
                message: message,
                technicalMessage: technicalMessage,
                underlyingError: nil)
        }
        
        return error
    }
    
}

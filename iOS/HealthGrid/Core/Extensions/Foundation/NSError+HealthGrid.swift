import Foundation

extension NSError {

    convenience init(domain: String!, code: Int, message: String!, technicalMessage: String?, underlyingError: NSError?) {
        var userInfo: [String : AnyObject] = [NSLocalizedDescriptionKey : message as AnyObject]
        
        if technicalMessage != nil {
            userInfo[NSLocalizedFailureReasonErrorKey] = technicalMessage! as AnyObject
        }
        if underlyingError != nil {
            userInfo[NSUnderlyingErrorKey] = underlyingError! as AnyObject
        }
        
        self.init(domain: domain, code: code, userInfo: userInfo)
    }
}

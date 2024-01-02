import Foundation

struct UtmUriBuilder {
    let rawUri: URL
    let activityType: UIActivity.ActivityType?
    
    init(_ rawUri: URL, _ activityType: UIActivity.ActivityType? = nil) {
        self.rawUri = rawUri
        self.activityType = activityType
    }
    
    func build() -> URL {
        guard let activityType = activityType else {
            return rawUri
        }
        
        // Append utm_source and utm_target parameters based on the activityType
        let utmSource: String
        switch activityType {
        case .mail:
            utmSource = "mail"
            break
        case .postToTwitter:
            utmSource = "twitter"
            break
        case .postToFacebook:
            utmSource = "facebook"
            break
        case .message:
            utmSource = "sms"
            break
        default:
            // TODO Test well-known apps and see what activityType they give (Facebook, X, ...)
            if let dot = activityType.rawValue.lastIndex(of: ".") {
                // Remove the prefix before the last dot
                utmSource = String(activityType.rawValue[activityType.rawValue.index(after: dot)...])
            } else {
                utmSource = activityType.rawValue
            }
        }
        let utmMedium: String
        switch activityType {
        case .mail:
            utmMedium = "email"
            break
        default:
            utmMedium = "social"
        }
        let utmItems = [
            URLQueryItem(name: "utm_source", value: utmSource),
            URLQueryItem(name: "utm_medium", value: utmMedium)
        ]
        
        guard var components = URLComponents(url: rawUri, resolvingAgainstBaseURL: false) else {
            return rawUri
        }
        
        components.queryItems = (components.queryItems ?? []) + utmItems
        return components.url ?? rawUri
    }
}

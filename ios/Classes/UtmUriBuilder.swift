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
            utmSource = "x"
            break
        case .postToFacebook:
            utmSource = "facebook"
            break
        case .message:
            utmSource = "sms"
            break
        default:
            switch activityType.rawValue {
            case "net.whatsapp.WhatsApp.ShareExtension":
                utmSource = "whatsapp"
                break
            case "com.burbn.instagram.shareextension":
                utmSource = "instagram"
                break
            case "com.burbn.barcelona.ShareExtension":
                utmSource = "threads"
                break
            case "xyz.blueskyweb.app.Share-with-Bluesky":
                utmSource = "bluesky"
                break
            case "org.mozilla.ios.Focus.ShareTo", "org.mozilla.ios.Firefox.ShareTo":
                utmSource = "firefox"
                break
            case "ch.protonmail.protonmail.Share", "com.zoho.zmail.ZohoMailShare":
                utmSource = "mail"
                break
            default:
                if let dot = activityType.rawValue.lastIndex(of: ".") {
                    // Remove the prefix before the last dot
                    utmSource = String(activityType.rawValue[activityType.rawValue.index(after: dot)...])
                } else {
                    utmSource = activityType.rawValue
                }
            }
        }
        let utmMedium: String
        switch activityType {
        case .mail:
            utmMedium = "email"
            break
        default:
            switch activityType.rawValue {
            case "org.mozilla.ios.Focus.ShareTo", "org.mozilla.ios.Firefox.ShareTo":
                utmMedium = "web"
                break
            case "ch.protonmail.protonmail.Share", "com.zoho.zmail.ZohoMailShare":
                utmMedium = "email"
                break
            default:
                utmMedium = "social"
            }
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

import Foundation
import os

class LinkToShare: NSObject, UIActivityItemSource {
    let link: URL
    let subject: String?

    init(link: URL, subject: String? = nil) {
        self.link = link
        self.subject = subject
    }
    
    func activityViewControllerPlaceholderItem(_ activityViewController: UIActivityViewController) -> Any {
        return link
    }
    
    func activityViewController(_ activityViewController: UIActivityViewController, itemForActivityType activityType: UIActivity.ActivityType?) -> Any? {
        return UtmUriBuilder(link, activityType).build()
    }

    func activityViewController(_ activityViewController: UIActivityViewController, subjectForActivityType activityType: UIActivity.ActivityType?) -> String {
        return subject ?? ""
    }
}

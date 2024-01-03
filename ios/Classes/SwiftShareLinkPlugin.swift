import Flutter
import UIKit

public class SwiftShareLinkPlugin: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "share_link", binaryMessenger: registrar.messenger())
    let instance = SwiftShareLinkPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
      if call.method != "shareUri" {
          result(FlutterMethodNotImplemented)
          return
      }
      
      // Get method arguments
      let args = call.arguments as? [String: Any]
      guard let raw = args?["uri"] as? String, let uri = URL(string: raw) else {
          return result(FlutterError(code: "error", message: "No (valid) uri given", details: nil))
      }
      let subject = args?["subject"] as? String
      
      // Get root view controller to open share dialog
      guard let rootViewController = UIApplication.shared.keyWindow?.rootViewController else {
          return result(FlutterError(code: "error", message: "No root view controller", details: nil))
      }
      
      // Open share dialog
      let items = [LinkToShare(link: uri, subject: subject)]
      let ac = UIActivityViewController(activityItems: items, applicationActivities: nil)
      
      if let subject = subject {
          // If a subject was given, use it as view controller subject
          ac.setValue(subject, forKey: "subject")
      }
      
      // Set up popover source for iPad
      if let ppc = ac.popoverPresentationController {
          guard let x = args?["shareOriginX"] as? Double, let y = args?["shareOriginY"] as? Double, let w = args?["shareOriginW"] as? Double, let h = args?["shareOriginH"] as? Double else {
              return result(FlutterError(code: "error", message: "Sharing on iPad required [shareOrigin] to be set", details: nil))
          }
          ppc.sourceView = rootViewController.view
          ppc.sourceRect = CGRect(x: x, y: y, width: w, height: h)
      }
      
      // Set up callback to report the chosen target
      ac.completionWithItemsHandler = { (activityType, completed, returnedItems, error) in
          if let activityType = activityType {
              result(["success": completed, "uri": UtmUriBuilder(uri, activityType).build().absoluteString, "target": activityType.rawValue])
          } else {
              result(["success": completed, "uri": uri.absoluteString])
          }
      }
      
      rootViewController.present(ac, animated: true)
  }
}

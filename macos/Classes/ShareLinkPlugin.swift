import Cocoa
import AppKit
import FlutterMacOS

public class ShareLinkPlugin: NSObject, FlutterPlugin, NSSharingServiceDelegate {
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "share_link", binaryMessenger: registrar.messenger)
        let instance = ShareLinkPlugin(registrar: registrar)
        registrar.addMethodCallDelegate(instance, channel: channel)
    }
    
    var sharingDelegate: SharingDelegate?
    let registrar: FlutterPluginRegistrar
    
    init(registrar: FlutterPluginRegistrar) {
        self.registrar = registrar
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
        guard let x = args?["shareOriginX"] as? Double, let y = args?["shareOriginY"] as? Double, let w = args?["shareOriginW"] as? Double, let h = args?["shareOriginH"] as? Double else {
            return result(FlutterError(code: "error", message: "Sharing on MacOS required [shareOrigin] to be set", details: nil))
        }
        let origin = NSMakeRect(x, y, w, h)
        
        // Open share dialog
        DispatchQueue.main.async {
            let ss = NSSharingServicePicker(items: [uri.absoluteString])
            self.sharingDelegate = SharingDelegate(ss, result, uri)
            ss.delegate = self.sharingDelegate
            ss.show(relativeTo: origin, of: self.registrar.view!, preferredEdge: .minY)
        }
    }
    
    class SharingDelegate: NSObject, NSSharingServicePickerDelegate {
        let picker: NSSharingServicePicker
        let resultCallback: FlutterResult
        let uri: URL
        
        init(_ picker: NSSharingServicePicker, _ resultCallback: @escaping FlutterResult, _ uri: URL) {
            self.picker = picker
            self.resultCallback = resultCallback
            self.uri = uri
        }
        
        func sharingServicePicker(_ sharingServicePicker: NSSharingServicePicker, didChoose service: NSSharingService?) {
            picker.delegate = nil
            
            guard let target = service?.menuItemTitle.lowercased() else {
                // No target, so nothing was selected
                resultCallback(["success": false, "uri": uri.absoluteString])
                return
            }
            resultCallback(["success": true, "uri": uri.absoluteString, "target": target])
        }
    }
}

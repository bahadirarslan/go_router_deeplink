import UIKit
import Flutter
import Photos
@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
    private var schemePrefix = "ImportMedia";
    let kEventsChannelMedia: String = "group.com.bahadirarslan.gorouter.extension/import"
        
        public var initialMedia: [ImportedFile]? = nil
        public var latestMedia: [ImportedFile]? = nil
        
        private var eventSinkMedia: FlutterEventSink? = nil;
        public var eventChannel: FlutterEventChannel!;
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)
      initFlutterChannel()
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
    
    override func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        initFlutterChannel()

        if (self.hasMatchingSchemePrefix(url: url)) {
            let result =  self.handleUrl(url: url, setInitialData: false)
            return super.application(app, open: url, options:options)
        }

        return super.application(app, open: url, options:options)
    }
    
    private func initFlutterChannel() {
        if let controller = window?.rootViewController as? FlutterViewController {
            eventChannel = FlutterEventChannel(name: kEventsChannelMedia, binaryMessenger: controller.binaryMessenger)
            eventChannel.setStreamHandler(self)
        }
       }
}

extension AppDelegate: FlutterStreamHandler {
    public func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        if (arguments as! String? == "media") {
            eventSinkMedia = events
        } else {
            return FlutterError.init(code: "NO_SUCH_ARGUMENT", message: "No such argument\(String(describing: arguments))", details: nil);
        }
        return nil;
    }
    
    public func onCancel(withArguments arguments: Any?) -> FlutterError? {
//        eventSinkMedia = nil
        return nil;
    }
}
// MARK: - URL Handling related
extension AppDelegate {
   
    func hasMatchingSchemePrefix(url: URL?) -> Bool {
        guard let url = url, let appDomain = Bundle.main.bundleIdentifier else {
            return false
        }
        
        return url.absoluteString == "gorouterapp://image-capture"
    }
    
    public func handleUrl(url: URL?, setInitialData: Bool) -> Bool {
        if let url = url {
            let appGroupId = "group.com.bahadirarslan.gorouter.extension"
            
            let userDefaults = UserDefaults(suiteName: appGroupId)

            if
                let json = userDefaults?.object(forKey: "ImportKey") as? Data {
                let sharedArray = decode(data: json)
                let sharedMediaFiles: [ImportedFile] = sharedArray.compactMap {
                    guard let path = getAbsolutePath(for: $0.path) else {
                        return nil
                    }
                    
                    return ImportedFile.init(
                        path: path,
                        name: $0.name
                    )
                }

                latestMedia = sharedMediaFiles
                if(setInitialData) {
                    initialMedia = latestMedia
                }
                
                self.eventSinkMedia?(toJson(data: latestMedia))
            }
            return true
        }
        latestMedia = nil
        return false
    }
    
    private func getAbsolutePath(for identifier: String) -> String? {
        if (identifier.starts(with: "file://")) {
            return identifier.replacingOccurrences(of: "file://", with: "")
        }
        let phAsset = PHAsset.fetchAssets(withLocalIdentifiers: [identifier], options: .none).firstObject
        if(phAsset == nil) {
            return nil
        }
        return getAssetUrl(for: phAsset!)
    }
    
    private func getAssetUrl(for asset: PHAsset)-> (String?) {
        var url: String? = nil
        let semaphore = DispatchSemaphore(value: 0)
        let options2 = PHContentEditingInputRequestOptions()
        options2.isNetworkAccessAllowed = true
        asset.requestContentEditingInput(with: options2){(input, info) in
            url = input?.fullSizeImageURL?.path
            semaphore.signal()
        }
        semaphore.wait()
        return url
    }
    
    private func decode(data: Data) -> [ImportedFile] {
        let encodedData = try? JSONDecoder().decode([ImportedFile].self, from: data)
        return encodedData!
    }
    
    private func toJson(data: [ImportedFile]?) -> String? {
        if data == nil {
            return nil
        }
        let encodedData = try? JSONEncoder().encode(data)
        let json = String(data: encodedData!, encoding: .utf8)!
        return json
    }
}


class ImportedFile: Codable {
    var path: String;
    var name: String;
    
    init(path: String, name: String) {
        self.path = path
        self.name = name
    }
}

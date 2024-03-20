//
//  ActionViewController.swift
//  extension.action
//
//  Created by Bahadir ARSLAN on 20.03.2024.
//

import UIKit
import MobileCoreServices
import UniformTypeIdentifiers

class ActionViewController: UIViewController {
    var hostAppBundleIdentifier = "com.bahadirarslan.goRouterDeeplink"
        let sharedKey = "ImportKey"
        var appGroupId = "group.com.bahadirarslan.gorouter.extension"
    var imageURL: URL?
    
    var importedMedia: [ImportedFile] = []
    @IBOutlet weak var imageView: UIImageView!

    override func viewDidLoad() {
        super.viewDidLoad()
    
        // Get the item[s] we're handling from the extension context.
        
        // For example, look for an image and place it into an image view.
        // Replace this with something appropriate for the type[s] your extension supports.
        loadIds()
        var imageFound = false
        for item in self.extensionContext!.inputItems as! [NSExtensionItem] {
            for provider in item.attachments! {
                if provider.hasItemConformingToTypeIdentifier(UTType.image.identifier) {
                    // This is an image. We'll load it, then place it in our image view.
                    weak var weakImageView = self.imageView
                    provider.loadItem(forTypeIdentifier: UTType.image.identifier, options: nil, completionHandler: { (imageURL, error) in
                        OperationQueue.main.addOperation {
                            if let strongImageView = weakImageView {
                                if let imageURL = imageURL as? URL {
                                    self.imageURL = imageURL
                                    strongImageView.image = UIImage(data: try! Data(contentsOf: imageURL))
                                }
                            }
                        }
                    })
                    
                    imageFound = true
                    break
                }
            }
            
            if (imageFound) {
                // We only handle one image, so stop looking for more.
                break
            }
        }
    }

    @IBAction func done() {
        guard let url = self.imageURL else {
            self.extensionContext!.completeRequest(returningItems: self.extensionContext!.inputItems, completionHandler: nil)
            return
        }
        let fileName = "\(url.deletingPathExtension().lastPathComponent).\(url.pathExtension)"
        let newPath = FileManager.default
            .containerURL(forSecurityApplicationGroupIdentifier: self.appGroupId)!
            .appendingPathComponent(fileName)
        let copied = self.copyFile(at: url, to: newPath)
        if (copied) {
            let sharedFile = ImportedFile(
                path: newPath.absoluteString,
                name: fileName
            )
            self.importedMedia.append(sharedFile)
        }

        let userDefaults = UserDefaults(suiteName: self.appGroupId)
        userDefaults?.set(self.toData(data: self.importedMedia), forKey: self.sharedKey)
        userDefaults?.synchronize()
        self.redirectToHostApp()
    }
    
    private func redirectToHostApp() {
           
         let url = URL(string: "gorouterapp://image-capture")
           var responder = self as UIResponder?
           let selectorOpenURL = sel_registerName("openURL:")

           while (responder != nil) {
               if (responder?.responds(to: selectorOpenURL))! {
                   let _ = responder?.perform(selectorOpenURL, with: url)
               }
               responder = responder!.next
           }
           extensionContext!.completeRequest(returningItems: [], completionHandler: nil)
       }
       
       private func loadIds() {
           let shareExtensionAppBundleIdentifier = Bundle.main.bundleIdentifier!;
       
           let lastIndexOfPoint = shareExtensionAppBundleIdentifier.lastIndex(of: ".");
           hostAppBundleIdentifier = String(shareExtensionAppBundleIdentifier[..<lastIndexOfPoint!]);

           appGroupId = (Bundle.main.object(forInfoDictionaryKey: "AppGroupId") as? String) ?? "group.\(hostAppBundleIdentifier)";
       }
       
       func toData(data: [ImportedFile]) -> Data {
          let encodedData = try? JSONEncoder().encode(data)
          return encodedData!
       }
       
       func copyFile(at srcURL: URL, to dstURL: URL) -> Bool {
           do {
               if FileManager.default.fileExists(atPath: dstURL.path) {
                   try FileManager.default.removeItem(at: dstURL)
               }
               try FileManager.default.copyItem(at: srcURL, to: dstURL)
           } catch (let error) {
               print("Cannot copy item at \(srcURL) to \(dstURL): \(error)")
               return false
           }
           return true
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

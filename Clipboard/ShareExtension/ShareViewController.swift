//
//  ShareViewController.swift
//  ShareExtension
//
//  Created by ybw-macbook-pro on 2023/2/21.
//

import UIKit
import Social

class ShareViewController: SLComposeServiceViewController {
    override func isContentValid() -> Bool {
        // Do validation of contentText and/or NSExtensionContext attachments here
        return true
    }

    override func didSelectPost() {
        // This is called after the user selects Post. Do the upload of contentText and/or NSExtensionContext attachments.
    
        // Inform the host that we're done, so it un-blocks its UI. Note: Alternatively you could call super's -didSelectPost, which will similarly complete the extension context.
        
        guard let inputItems = self.extensionContext?.inputItems.map({ $0 as? NSExtensionItem }) else {
            self.extensionContext?.cancelRequest(withError: NSError())
            return
        }
        
        for inputItem in inputItems {
            guard let contentText = inputItem?.attributedContentText else { return }
            
            let userDefaults = UserDefaults.init(suiteName: "group.ybwdaisy.clipboard")
            userDefaults?.set(contentText.string, forKey: "share_extension_content")
        }
        self.extensionContext!.completeRequest(returningItems: [], completionHandler: nil)
    }

    override func configurationItems() -> [Any]! {
        // To add configuration options via table cells at the bottom of the sheet, return an array of SLComposeSheetConfigurationItem here.
        return []
    }

}

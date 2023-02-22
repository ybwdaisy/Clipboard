//
//  ShareViewController.swift
//  ShareExtension
//
//  Created by ybw-macbook-pro on 2023/2/21.
//

import UIKit
import Social
import SwiftUI
import CoreData

class ShareViewController: SLComposeServiceViewController {
    override func isContentValid() -> Bool {
        // Do validation of contentText and/or NSExtensionContext attachments here
        return true
    }
    
    override func viewDidLoad() {
        let viewContext = PersistenceController.shared.container.viewContext
        let fetchRequest: NSFetchRequest = Clipboards.fetchRequest()
        guard let clipboards = try? viewContext.fetch(fetchRequest) as! [Clipboards] else { return }
        clipboards.forEach { item in
            print("clipboard extension", item.text)
        }
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
            print(contentText.string)
            
            let viewContext = PersistenceController.shared.container.viewContext
            let newItem = Clipboards(context: viewContext)
            newItem.text = contentText.string
            
            try? viewContext.save()
        }
        self.extensionContext!.completeRequest(returningItems: [], completionHandler: nil)
    }

    override func configurationItems() -> [Any]! {
        // To add configuration options via table cells at the bottom of the sheet, return an array of SLComposeSheetConfigurationItem here.
        return []
    }

}

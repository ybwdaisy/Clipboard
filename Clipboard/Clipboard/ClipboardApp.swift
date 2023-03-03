//
//  ClipboardApp.swift
//  Clipboard
//
//  Created by ybw-macbook-pro on 2023/2/20.
//

import SwiftUI

@main
struct ClipboardApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, PersistenceController(inMemory: true).container.viewContext)
        }
    }
}

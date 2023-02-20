//
//  ContentView.swift
//  Clipboard
//
//  Created by ybw-macbook-pro on 2023/2/20.
//

import SwiftUI
import CoreData

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Clipboards.objectID, ascending: true)],
        animation: .default)
    private var items: FetchedResults<Clipboards>

    var body: some View {
        NavigationView {
            List {
                ForEach(items, id: \.objectID) { item in
                    NavigationLink {
                        Text(item.text)
                    } label: {
                        Text(item.text)
                    }
                }
                .onDelete(perform: deleteItems)
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    EditButton()
                }
            }
            .navigationTitle("Clipboard History")
            .onAppear {
                let clipboard = UIPasteboard.general.string
                if (clipboard != nil) {
                    addItem(str: clipboard ?? "")
                    UIPasteboard.general.string = nil
                }
            }
        }
    }

    private func addItem(str: String) {
        withAnimation {
            let newItem = Clipboards(context: viewContext)
            newItem.text = str

            do {
                try viewContext.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }

    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            offsets.map { items[$0] }.forEach(viewContext.delete)

            do {
                try viewContext.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environment(\.managedObjectContext, PersistenceController.shared.container.viewContext)
    }
}

//
//  ContentView.swift
//  Clipboard
//
//  Created by ybw-macbook-pro on 2023/2/20.
//

import SwiftUI
import CoreData

struct ContentView: View {
    @Environment(\.scenePhase) private var scenePhase
    
    @Environment(\.managedObjectContext) private var viewContext

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Clipboards.objectID, ascending: true)],
        animation: .default)
    private var items: FetchedResults<Clipboards>

    var body: some View {
        NavigationView {
            List(items, id: \.objectID) { item in
                Text(item.text)
                    .swipeActions(edge: .leading) {
                        Button {
                            copyItems(text: item.text)
                        } label: {
                            Label("Copy", systemImage: "doc.on.doc")
                        }
                        .tint(.blue)
                        Button {
                            topItems(item: item)
                        } label: {
                            Label("Top", systemImage: "pin")
                        }
                        .tint(.green)
                    }
                    .swipeActions(edge: .trailing) {
                        Button {
                            deleteItems(item: item)
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                        .tint(.red)
                    }
                    .contextMenu {
                        Button {
                            copyItems(text: item.text)
                        } label: {
                            Label("Copy", systemImage: "doc.on.doc")
                        }
                        Button {
                            topItems(item: item)
                        } label: {
                            Label("Top", systemImage: "pin")
                        }
                        Button(role: .destructive) {
                            deleteItems(item: item)
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                    }
            }
            .navigationTitle("Clipboard History")
            .onChange(of: scenePhase, perform: { newPhase in
                if newPhase == .active {
                    print("active")
                    let clipboardString = UIPasteboard.general.string
                    if (clipboardString != nil) {
                        addItem(text: clipboardString ?? "")
                        UIPasteboard.general.string = nil
                    }
                } else if newPhase == .inactive {
                    print("inactive")
                } else if newPhase == .background {
                    print("background")
                }
            })
            .onAppear {
                let fetchRequest: NSFetchRequest = Clipboards.fetchRequest()
                guard let clipboards = try? viewContext.fetch(fetchRequest) as! [Clipboards] else { return }
                clipboards.forEach { item in
                    print("clipboard app", item.text)
                }
            }
        }
    }

    private func addItem(text: String) {
        withAnimation {
            let newItem = Clipboards(context: viewContext)
            newItem.text = text

            do {
                try viewContext.save()
            } catch {
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }
    
    private func deleteItems(item: Clipboards) {
        withAnimation {
            viewContext.delete(item)
            do {
                try viewContext.save()
            } catch {
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
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }
    
    private func copyItems(text: String) {
        withAnimation {
            UIPasteboard.general.string = text
        }
    }
    
    private func topItems(item: Clipboards) {
        
    }
    
    private func selectItems() {
        
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environment(\.managedObjectContext, PersistenceController.shared.container.viewContext)
    }
}

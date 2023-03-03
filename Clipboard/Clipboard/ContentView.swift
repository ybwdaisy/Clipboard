//
//  ContentView.swift
//  Clipboard
//
//  Created by ybw-macbook-pro on 2023/2/20.
//

import SwiftUI
import CoreData

struct ContentView: View {
    @State private var selection = Set<NSManagedObjectID>()
    @State private var sharePresented: Bool = false
    @State private var activityItems: [Any] = []
    
    @Environment(\.scenePhase) private var scenePhase
    
    @Environment(\.managedObjectContext) private var viewContext

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Clipboards.objectID, ascending: true)],
        animation: .default)
    private var items: FetchedResults<Clipboards>

    var body: some View {
        NavigationView {
            List(items, id: \.objectID, selection: $selection) { item in
                Text(item.text)
                    .swipeActions(edge: .leading) {
                        Button {
                            copyItems(text: item.text)
                        } label: {
                            Image(systemName: "doc.on.doc")
                        }
                        .tint(.blue)
                        Button {
                            topItems(item: item)
                        } label: {
                            Image(systemName: "pin")
                        }
                        .tint(.green)
                    }
                    .swipeActions(edge: .trailing) {
                        Button {
                            deleteItems(item: item)
                        } label: {
                            Image(systemName: "trash")
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
                        Button {
                            shareItems(item: item)
                        } label: {
                            Label("Share", systemImage: "square.and.arrow.up")
                        }
                        Button(role: .destructive) {
                            deleteItems(item: item)
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                    }
            }
            .toolbar {
                EditButton()
            }
            .navigationTitle("Clipboard History")
            .onChange(of: scenePhase, perform: { newPhase in
                if newPhase == .active {
                    // from clipboard
                    let clipboardString = UIPasteboard.general.string
                    if (clipboardString != nil) {
                        addItem(text: clipboardString!)
                        UIPasteboard.general.string = nil
                    }
                }
            })
            .sheet(isPresented: $sharePresented, onDismiss: nil) {
                ActivityViewController(activityItems: $activityItems)
            }
        }
        Group {
            if !selection.isEmpty {
                HStack {
                    Button {
                        
                    } label: {
                        Image(systemName: "doc.on.doc")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 20.0)
                    }
                    Spacer()
                    Button {
                        
                    } label: {
                        Image(systemName: "pin")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 17.0)
                    }
                    Spacer()
                    Button {
                        
                    } label: {
                        Image(systemName: "square.and.arrow.up")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 18.0)
                    }
                    Spacer()
                    Button(role: .destructive) {
                        
                    } label: {
                        Image(systemName: "trash")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 20.0)
                    }
                }
                .padding(EdgeInsets(top: 0, leading: 20.0, bottom: 0, trailing: 20.0))
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
    
    private func copyItems(text: String) {
        withAnimation {
            UIPasteboard.general.string = text
        }
    }
    
    private func topItems(item: Clipboards) {
        
    }
    
    private func shareItems(item: Clipboards) {
        sharePresented = true
        activityItems = [item.text]
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environment(\.managedObjectContext, PersistenceController(inMemory: true).container.viewContext)
    }
}

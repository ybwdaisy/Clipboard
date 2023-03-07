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
    @State private var editMode = EditMode.inactive
    @State private var sharePresented: Bool = false
    @State private var activityItems: [String] = []
    @State private var searchText: String = ""
    
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
                    .listRowBackground(item.top ? Color.gray.opacity(0.3) : nil)
                    .swipeActions(edge: .leading) {
                        Button {
                            copyItems(items: [item])
                        } label: {
                            Image(systemName: "doc.on.doc")
                        }
                        .tint(.blue)
                        Button {
                            topItems(items: [item])
                        } label: {
                            Image(systemName: item.top ? "pin.slash" : "pin")
                        }
                        .tint(.green)
                    }
                    .swipeActions(edge: .trailing) {
                        Button {
                            deleteItems(items: [item])
                        } label: {
                            Image(systemName: "trash")
                        }
                        .tint(.red)
                    }
                    .contextMenu {
                        Button {
                            copyItems(items: [item])
                        } label: {
                            Label("Copy", systemImage: "doc.on.doc")
                        }
                        Button {
                            topItems(items: [item])
                        } label: {
                            Label(item.top ? "UnTop": "Top", systemImage: item.top ? "pin.slash" : "pin")
                        }
                        Button {
                            shareItems(items: [item])
                        } label: {
                            Label("Share", systemImage: "square.and.arrow.up")
                        }
                        Button(role: .destructive) {
                            deleteItems(items: [item])
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                    }
            }
            .toolbar {
                EditButton()
            }
            .environment(\.editMode, $editMode)
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
            .searchable(text: $searchText, prompt: "Search Clipboard")
        }
        Group {
            if selection.count > 0 {
                HStack {
                    Button {
                        copyItems(items: selection)
                    } label: {
                        Image(systemName: "doc.on.doc")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 20.0)
                    }
                    Spacer()
                    Button {
                        topItems(items: selection)
                    } label: {
                        Image(systemName: "pin")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 17.0)
                    }
                    Spacer()
                    Button {
                        shareItems(items: selection)
                    } label: {
                        Image(systemName: "square.and.arrow.up")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 18.0)
                    }
                    Spacer()
                    Button(role: .destructive) {
                        deleteItems(items: selection)
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
    
    private func viewContextSave() {
        do {
            try viewContext.save()
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
    }

    private func addItem(text: String) {
        withAnimation {
            let newItem = Clipboards(context: viewContext)
            newItem.text = text
            viewContext.insert(newItem)
            viewContextSave()
        }
    }
    
    private func deleteItems(items: [Clipboards]) {
        withAnimation {
            items.forEach { item in
                viewContext.delete(item)
            }
            viewContextSave()
        }
    }
    
    private func deleteItems(items: Set<NSManagedObjectID>) {
        withAnimation {
            items.forEach { objectID in
                let item = viewContext.object(with: objectID)
                viewContext.delete(item)
            }
            viewContextSave()
        }
    }
    
    private func copyItems(items: [Clipboards]) {
        withAnimation {
            var texts: [String] = []
            items.forEach { item in
                texts.append(item.text)
            }
            UIPasteboard.general.string = texts.joined(separator: "\n")
        }
    }
    
    private func copyItems(items: Set<NSManagedObjectID>) {
        withAnimation {
            var texts: [String] = []
            items.forEach { objectID in
                let item: Clipboards = viewContext.object(with: objectID) as! Clipboards
                texts.append(item.text)
            }
            UIPasteboard.general.string = texts.joined(separator: "\n")
        }
    }
    
    private func topItems(items: [Clipboards]) {
        withAnimation {
            items.forEach { item in
                item.top = !item.top
            }
            viewContextSave()
        }
    }
    
    private func topItems(items: Set<NSManagedObjectID>) {
        items.forEach { objectID in
            let item: Clipboards = viewContext.object(with: objectID) as! Clipboards
            item.top = true
        }
        viewContextSave()
    }
    
    private func shareItems(items: [Clipboards]) {
        sharePresented = true
        var texts: [String] = []
        items.forEach { item in
            texts.append(item.text)
        }
        activityItems = texts
    }
    
    private func shareItems(items: Set<NSManagedObjectID>) {
        sharePresented = true
        var texts: [String] = []
        items.forEach { objectID in
            let item: Clipboards = viewContext.object(with: objectID) as! Clipboards
            texts.append(item.text)
        }
        activityItems = texts
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environment(\.managedObjectContext, PersistenceController(inMemory: true).container.viewContext)
    }
}

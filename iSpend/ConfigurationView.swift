import Combine
import Foundation
import SwiftUI

struct ConfigurationView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var categories: Categories
    @EnvironmentObject var mediations: Mediations
    
    @State private var showingAddMediations = false
    @State private var showingAddCategories = false
    @State private var editingText: String = "" // State to hold the text being edited or added

    
    var body: some View {
        NavigationView {
            EditListView(deleteItems: removeCategories, items: $categories.items)
                .navigationTitle("Categories")
                .toolbar {
                    Button {
                        editingText = ""
                        showingAddCategories = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
        }
        .sheet(isPresented: $showingAddCategories) {
            AddOrEditItemView(itemText: editingText) { newText in
                if !newText.isEmpty {
                    categories.appendItem(category: Category(name: newText))
                }
            }.environmentObject(categories)
        }

        NavigationView {
            EditListView(deleteItems: removeMediations, items: $mediations.items)
                .navigationTitle("Mediations")
                .toolbar {
                    Button {
                        editingText = "" // Reset or set to a default value for adding a new item
                        showingAddMediations = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
        }
        .sheet(isPresented: $showingAddMediations) {
            AddOrEditItemView(itemText: editingText) { newText in
                // Handle saving the edited or new text
                if !newText.isEmpty {
                    mediations.appendItem(mediation: Mediation(name: newText))
                }
            }.environmentObject(mediations)
        }
    }

    func removeCategories(at offsets: IndexSet) {
        var objectsToDelete = IndexSet()
        for offset in offsets {
            let item = categories.items[offset]
            if let index = categories.items.firstIndex(of: item) {
                objectsToDelete.insert(index)
            }
        }
 
    }

    func removeMediations(at offsets: IndexSet) {
        var objectsToDelete = IndexSet()
        for offset in offsets {
            let item = mediations.items[offset]
            if let index = mediations.items.firstIndex(of: item) {
                objectsToDelete.insert(index)
            }
        }
        mediations.refreshData()
    }
}

struct AddOrEditItemView: View {
    @Environment(\.dismiss) var dismiss
    var onSave: (String) -> Void
    @State private var itemText: String

    init(itemText: String = "", onSave: @escaping (String) -> Void) {
        _itemText = State(initialValue: itemText)
        self.onSave = onSave
    }

    var body: some View {
        NavigationView {
            TextField("Enter item", text: $itemText)
                .padding()
                .navigationTitle("Edit Item")
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button("Cancel") {
                            dismiss()
                        }
                    }
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Save") {
                            onSave(itemText)
                            dismiss()
                        }
                    }
                }
        }
    }
}

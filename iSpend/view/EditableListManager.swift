//
//  EditableListManager.swift
//  iSpend
//
//  A reusable component for managing editable lists (categories, mediations)
//

import SwiftUI
import SwiftData

struct EditableListManager: View {
    let title: String
    let itemType: Int
    let placeholder: String

    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Query private var allItems: [EditableListItem]

    @State private var showingAddSheet = false
    @State private var newItemText = ""
    @State private var editMode: EditMode = .inactive

    private var filteredItems: [EditableListItem] {
        allItems.filter { $0.type == itemType }
    }

    init(title: String, itemType: Int, placeholder: String = "New Item") {
        self.title = title
        self.itemType = itemType
        self.placeholder = placeholder
    }

    var body: some View {
        NavigationStack {
            List {
                ForEach(filteredItems) { item in
                    EditableListRow(item: item)
                }
                .onDelete(perform: deleteItems)
                .onMove(perform: moveItems)

                if editMode == .inactive {
                    AddNewItemRow(text: $newItemText, placeholder: placeholder) {
                        addItem()
                    }
                }
            }
            .navigationTitle(title)
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItemGroup(placement: .navigationBarLeading) {
                    Button("Done") {
                        dismiss()
                    }
                }
                ToolbarItemGroup(placement: .navigationBarTrailing) {
                    EditButton()
                }
            }
            .environment(\.editMode, $editMode)
        }
    }

    private func addItem() {
        guard !newItemText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }

        let newItem = EditableListItem(text: newItemText, type: itemType)
        modelContext.insert(newItem)
        newItemText = ""

        do {
            try modelContext.save()
        } catch {
            print("Failed to save item: \(error)")
        }
    }

    private func deleteItems(at offsets: IndexSet) {
        for index in offsets {
            let item = filteredItems[index]
            modelContext.delete(item)
        }

        do {
            try modelContext.save()
        } catch {
            print("Failed to delete items: \(error)")
        }
    }

    private func moveItems(from source: IndexSet, to destination: Int) {
        // SwiftData handles ordering through the query
        // For custom ordering, you'd need to add an order property to the model
    }
}

struct EditableListRow: View {
    let item: EditableListItem
    @State private var editedText: String
    @FocusState private var isFocused: Bool
    @Environment(\.modelContext) private var modelContext

    init(item: EditableListItem) {
        self.item = item
        self._editedText = State(initialValue: item.text)
    }

    var body: some View {
        TextField("Item", text: $editedText)
            .focused($isFocused)
            .submitLabel(.done)
            .onSubmit {
                saveChanges()
            }
            .onChange(of: isFocused) { _, newValue in
                if !newValue {
                    saveChanges()
                }
            }
    }

    private func saveChanges() {
        if editedText != item.text {
            item.text = editedText
            do {
                try modelContext.save()
            } catch {
                print("Failed to save changes: \(error)")
            }
        }
    }
}

struct AddNewItemRow: View {
    @Binding var text: String
    let placeholder: String
    let onCommit: () -> Void
    @FocusState private var isFocused: Bool

    var body: some View {
        HStack {
            Image(systemName: "plus.circle.fill")
                .foregroundColor(.accentColor)
                .imageScale(.large)

            TextField(placeholder, text: $text)
                .focused($isFocused)
                .submitLabel(.done)
                .onSubmit {
                    onCommit()
                    isFocused = false
                }
        }
    }
}

// Preview helper
struct EditableListManager_Previews: PreviewProvider {
    static var previews: some View {
        EditableListManager(title: "Categories", itemType: CATEGORY, placeholder: "Add Category")
            .modelContainer(for: [EditableListItem.self])
    }
}
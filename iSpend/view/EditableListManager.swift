//
//  EditableListManager.swift
//  iSpend
//
//  A reusable component for managing editable lists (categories, reflections)
//

import SwiftUI
import SwiftData

struct EditableListManager: View {
    let title: String
    let itemType: Int
    let placeholder: String

    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Query private var items: [EditableListItem]

    @State private var newItemText = ""
    @State private var editMode: EditMode = .inactive

    init(title: String, itemType: Int, placeholder: String = "New Item") {
        self.title = title
        self.itemType = itemType
        self.placeholder = placeholder
        let type = itemType
        _items = Query(filter: #Predicate<EditableListItem> { $0.type == type })
    }

    var body: some View {
        NavigationStack {
            List {
                ForEach(items) { item in
                    EditableListRow(item: item)
                }
                .onDelete(perform: deleteItems)

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
        let trimmed = newItemText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        // Prevent duplicates (case-insensitive).
        guard !items.contains(where: { $0.text.caseInsensitiveCompare(trimmed) == .orderedSame }) else {
            newItemText = ""
            return
        }
        let newItem = EditableListItem(text: trimmed, type: itemType)
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
            modelContext.delete(items[index])
        }
        do {
            try modelContext.save()
        } catch {
            print("Failed to delete items: \(error)")
        }
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

#Preview {
    EditableListManager(title: "Categories", itemType: CATEGORY, placeholder: "Add Category")
        .modelContainer(for: [EditableListItem.self])
}

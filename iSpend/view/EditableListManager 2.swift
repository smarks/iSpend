//
//  EditableListManager.swift
//  iSpend
//
//  Created by Spencer Marks on 8/27/24.
//

import Foundation
import SwiftData
import SwiftUI

struct EditableListManager: View {
    let title: String
    let itemType: Int
    let placeholder: String
    
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) var dismiss
    
    @Query private var items: [EditableListItem]
    @State private var newItemText: String = ""
    @State private var isAddingItem: Bool = false
    @State private var errorMessage: String?
    @State private var showingError: Bool = false
    @FocusState private var isTextFieldFocused: Bool
    
    init(title: String, itemType: Int, placeholder: String) {
        self.title = title
        self.itemType = itemType
        self.placeholder = placeholder
        
        // Filter items by type
        let predicate = #Predicate<EditableListItem> { item in
            item.type == itemType
        }
        _items = Query(filter: predicate, sort: [SortDescriptor(\.text)])
    }
    
    var body: some View {
        NavigationStack {
            VStack {
                List {
                    ForEach(items, id: \.id) { item in
                        HStack {
                            Text(item.text)
                                .font(.body)
                            Spacer()
                        }
                        .padding(.vertical, 2)
                        .accessibilityLabel("\(item.text), swipe to delete")
                    }
                    .onDelete(perform: deleteItems)
                    
                    if isAddingItem {
                        HStack {
                            TextField(placeholder, text: $newItemText)
                                .textFieldStyle(.roundedBorder)
                                .focused($isTextFieldFocused)
                                .onSubmit {
                                    addItem()
                                }
                            
                            Button("Cancel") {
                                cancelAddingItem()
                            }
                            .foregroundStyle(.red)
                        }
                        .padding(.horizontal)
                    }
                }
                
                if !isAddingItem {
                    Button(action: {
                        startAddingItem()
                    }) {
                        HStack {
                            Image(systemName: "plus.circle.fill")
                            Text("Add \(title.singularForm())")
                        }
                        .foregroundStyle(.blue)
                    }
                    .padding()
                }
            }
            .navigationTitle(title)
            .navigationBarTitleDisplayMode(.inline)
            .alert("Error", isPresented: $showingError) {
                Button("OK") { }
            } message: {
                Text(errorMessage ?? "An unknown error occurred")
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private func startAddingItem() {
        isAddingItem = true
        newItemText = ""
        isTextFieldFocused = true
    }
    
    private func cancelAddingItem() {
        isAddingItem = false
        newItemText = ""
        isTextFieldFocused = false
    }
    
    private func addItem() {
        guard !newItemText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            return
        }
        
        let trimmedText = newItemText.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Check for duplicates
        if items.contains(where: { $0.text.lowercased() == trimmedText.lowercased() }) {
            errorMessage = "This item already exists."
            showingError = true
            return
        }
        
        let newItem = EditableListItem(text: trimmedText, type: itemType)
        modelContext.insert(newItem)
        
        do {
            try modelContext.save()
            cancelAddingItem()
        } catch {
            errorMessage = "Failed to save item: \(error.localizedDescription)"
            showingError = true
        }
    }
    
    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                modelContext.delete(items[index])
            }
            
            do {
                try modelContext.save()
            } catch {
                errorMessage = "Failed to delete items: \(error.localizedDescription)"
                showingError = true
            }
        }
    }
}

extension String {
    func singularForm() -> String {
        if self.hasSuffix("ies") {
            return String(self.dropLast(3)) + "y"
        } else if self.hasSuffix("s") {
            return String(self.dropLast(1))
        } else {
            return self
        }
    }
}

#Preview {
    EditableListManager(title: "Categories", itemType: CATEGORY, placeholder: "Add Category")
        .modelContainer(for: EditableListItem.self, inMemory: true)
}
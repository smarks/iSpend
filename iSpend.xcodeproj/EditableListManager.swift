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
                            Spacer()
                        }
                    }
                    .onDelete(perform: deleteItems)
                    
                    if isAddingItem {
                        HStack {
                            TextField(placeholder, text: $newItemText)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .onSubmit {
                                    addItem()
                                }
                            
                            Button("Cancel") {
                                cancelAddingItem()
                            }
                            .foregroundColor(.red)
                        }
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
                        .foregroundColor(.blue)
                    }
                    .padding()
                }
            }
            .navigationTitle(title)
            .navigationBarTitleDisplayMode(.inline)
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
    }
    
    private func cancelAddingItem() {
        isAddingItem = false
        newItemText = ""
    }
    
    private func addItem() {
        guard !newItemText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            return
        }
        
        let newItem = EditableListItem(text: newItemText.trimmingCharacters(in: .whitespacesAndNewlines), type: itemType)
        modelContext.insert(newItem)
        
        do {
            try modelContext.save()
        } catch {
            print("Failed to save new item: \(error)")
        }
        
        cancelAddingItem()
    }
    
    private func deleteItems(offsets: IndexSet) {
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
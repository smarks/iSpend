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
                                .onChange(of: newItemText) { oldValue, newValue in
                                    // Limit input length in real-time
                                    if newValue.count > 100 {
                                        newItemText = String(newValue.prefix(100))
                                    }
                                }
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
        let trimmedText = newItemText.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Input validation
        guard !trimmedText.isEmpty else {
            return
        }
        
        // Prevent excessively long inputs (DoS protection)
        guard trimmedText.count <= 100 else {
            errorMessage = "Item name is too long. Please keep it under 100 characters."
            showingError = true
            return
        }
        
        // Sanitize input - remove potentially harmful characters
        let sanitizedText = sanitizeInput(trimmedText)
        guard !sanitizedText.isEmpty else {
            errorMessage = "Invalid characters in item name."
            showingError = true
            return
        }
        
        // Check for duplicates (case-insensitive)
        if items.contains(where: { $0.text.lowercased() == sanitizedText.lowercased() }) {
            errorMessage = "This item already exists."
            showingError = true
            return
        }
        
        let newItem = EditableListItem(text: sanitizedText, type: itemType)
        modelContext.insert(newItem)
        
        do {
            try modelContext.save()
            cancelAddingItem()
        } catch {
            errorMessage = "Failed to save item: \(error.localizedDescription)"
            showingError = true
        }
    }
    
    /// Sanitizes user input to prevent potential security issues
    private func sanitizeInput(_ input: String) -> String {
        // Remove control characters and non-printable characters
        let allowedCharacterSet = CharacterSet.alphanumerics
            .union(.punctuationCharacters)
            .union(.whitespaces)
            .union(.symbols)
        
        let sanitized = input.unicodeScalars
            .filter { allowedCharacterSet.contains($0) }
            .map { String($0) }
            .joined()
        
        // Further limit to reasonable characters for item names
        return sanitized.replacingOccurrences(of: "<", with: "")
                       .replacingOccurrences(of: ">", with: "")
                       .replacingOccurrences(of: "&", with: "and")
                       .trimmingCharacters(in: .whitespacesAndNewlines)
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
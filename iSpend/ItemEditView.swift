//
//  ItemEditView.swift
//  iSpend
//
//  Created by Spencer Marks on 3/13/24.
//

import Foundation
import SwiftUI

struct ItemEditView<T: NamedItem>: View {
    @Binding var item: T
    var onSave: (T) -> Void

    var body: some View {
        NavigationView {
            Form {
                TextField("Name", text: $item.name)
            }
            .navigationBarTitle("Edit Item", displayMode: .inline)
            .navigationBarItems(trailing: Button("Save") {
                onSave(item)
            })
        }
    }
}

struct ItemsListView<T: NamedItem>: View {
    @ObservedObject var itemsManager: ItemsManager<T>
    
    @State private var selectedItem: T?
    @State private var isEditingItem = false

    var body: some View {
        List {
            ForEach(itemsManager.items) { item in
                Text(item.name)
                    .onTapGesture {
                        self.selectedItem = item
                        self.isEditingItem = true
                    }
            }
        }
        .sheet(isPresented: $isEditingItem) {
            if let selectedItem = selectedItem {
                ItemEditView(item: .constant(selectedItem)) { editedItem in
                    if let index = itemsManager.items.firstIndex(where: { $0.id == editedItem.id }) {
                        itemsManager.items[index] = editedItem
                        itemsManager.saveItems()
                    }
                    isEditingItem = false
                }
            }
        }
    }
}


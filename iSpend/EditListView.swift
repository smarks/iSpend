//
//  EditListView.swift
//  iSpend
//
//  Created by Spencer Marks on 3/13/24.
//

import Foundation
import SwiftUI

protocol NamedItem: Identifiable, Codable, Equatable, Hashable {
    var id: UUID { get set }
    var name: String { get set }
}

struct EditListView<ItemType: NamedItem>: View {
    @Binding var items: [ItemType]

    
    var body: some View {
        List {
            ForEach($items, id: \.id) { $item in
                TextField("Name", text: $item.name)
            }
            .onDelete(perform: delete)
        }
        .navigationBarItems(trailing: EditButton())
    }
    
    private func delete(at offsets: IndexSet) {
        items.remove(atOffsets: offsets)
    }
}

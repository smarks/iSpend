//
//  EditListView.swift
//  iSpend
//
//  Created by Spencer Marks on 3/13/24.
//

import Foundation
import SwiftUI

protocol NamedItem: Identifiable, Codable, Equatable, Hashable , Encodable{
    var id: UUID { get set }
    var name: String { get set }
}

struct EditListView<ItemType: NamedItem>: View {
    let deleteItems: (IndexSet) -> Void

    @Binding var items: [ItemType]

    var body: some View {
        List {
            ForEach($items, id: \.id) { $item in
                Text(item.name)
            }
            .onDelete(perform: deleteItems)  
            .onTapGesture{
                print(items)
            }
        }
        .navigationBarItems(trailing: EditButton())
    }
    
  //  private func delete(at offsets: IndexSet) {
   //     items.remove(atOffsets: offsets)
   // }
}

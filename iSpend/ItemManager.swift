//
//  ItemManager.swift
//  iSpend
//
//  Created by Spencer Marks on 3/13/24.
//

import Foundation

class ItemsManager<T: NamedItem>: ObservableObject {
    @Published var items: [T] = []
    private let itemsKey: String

    init(itemsKey: String) {
        self.itemsKey = itemsKey
        loadItems()
    }

    private func loadItems() {
        if let savedItems = UserDefaults.standard.data(forKey: itemsKey),
           let decodedItems = try? JSONDecoder().decode([T].self, from: savedItems) {
            items = decodedItems
        }
    }

    func saveItems() {
        if let encoded = try? JSONEncoder().encode(items) {
            UserDefaults.standard.set(encoded, forKey: itemsKey)
        }
    }
}

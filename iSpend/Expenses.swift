//
//  Expenses.swift
//  iSpend
//
//  Original code created by Paul Hudson on 01/11/2021.
//  Extended by Spencer Marks starting on 07/25/2023
//

import Foundation

class Expenses: ObservableObject {
    @Published var items = [ExpenseItem]() {
        didSet {
            
            if let encoded = try? JSONEncoder().encode(items) {
                UserDefaults.standard.set(encoded, forKey: "Items")
            }
        }
    }

    var discretionaryItems: [ExpenseItem] {
        items.filter { $0.type == ExpenseType.Necessary }
    }

    var necessaryItems: [ExpenseItem] {
        items.filter { $0.type == ExpenseType.Discretionary }
    }

    init() {
      loadData()
    }
    
    func loadData() {
        if let savedItems = UserDefaults.standard.data(forKey: "Items") {
            if let decodedItems = try? JSONDecoder().decode([ExpenseItem].self, from: savedItems) {
                items = decodedItems
                return
            }
        }

        items = []
    }
}

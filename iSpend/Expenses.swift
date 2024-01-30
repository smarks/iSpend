//
//  Expenses.swift
//  iSpend
//
//  Original code created by Paul Hudson on 01/11/2021.
//  Extended by Spencer Marks starting on 07/25/2023
//

import Foundation

class Expenses: ObservableObject {
    @Published var allItems = [ExpenseItem]() {
        didSet {
            
            if let encoded = try? JSONEncoder().encode(allItems) {
                UserDefaults.standard.set(encoded, forKey: "Items")
            }
        }
    }

    var discretionaryItems: [ExpenseItem] {
        allItems.filter { $0.type == ExpenseType.Necessary }
    }

    var necessaryItems: [ExpenseItem] {
        allItems.filter { $0.type == ExpenseType.Discretionary }
    }

    init() {
      loadData()
    }
    
    func loadData() {
        if let savedItems = UserDefaults.standard.data(forKey: "Items") {
            if let decodedItems = try? JSONDecoder().decode([ExpenseItem].self, from: savedItems) {
                allItems = decodedItems
                return
            }
        }

        allItems = []
    }
}

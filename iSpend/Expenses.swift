//  Expenses.swift
//  iSpend
//
//  Original code created by Paul Hudson on 01/11/2021.
//  Extended by Spencer Marks starting on 07/25/2023
//


import Foundation
import SwiftUI

enum ExpenseType: String, Codable, Equatable {
    case necessary
    case discretionary
}

class ExpenseItem: Identifiable, Codable {
    var id = UUID()
    var name: String
    var type: ExpenseType
    var amount: Double
    var note: String
    var date: Date
    var category: String
    var discretionaryValue: Double
    
    init(name:String, type:ExpenseType, amount: Double, note:String, date: Date, category:String, discretionaryValue: Double){
        self.id = UUID()
        self.name = name
        self.type = type
        self.amount = amount
        self.note = note
        self.date = date
        self.category = category
        self.discretionaryValue = discretionaryValue
    }
}

@Observable
class Expenses {
     
   var allItems = [ExpenseItem]() {
        didSet {
            if let encoded = try? JSONEncoder().encode(allItems) {
                UserDefaults.standard.set(encoded, forKey: "Items")
            }
        }
    }

    var discretionaryItems: [ExpenseItem] {
        allItems.filter { $0.type == ExpenseType.discretionary }
    }

    var necessaryItems: [ExpenseItem] {
        allItems.filter { $0.type == ExpenseType.necessary }
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

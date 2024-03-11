//
//  ExpenseItem.swift
//  iSpend
//
//  Original code created by Paul Hudson on 01/11/2021.
//  Extended by Spencer Marks starting on 07/25/2023
//

import Foundation

struct ExpenseItem: Identifiable, Codable, Equatable {
  
    var id = UUID()
    var name: String
    var type: ExpenseType
    var amount: Double
    var note: String
    var date: Date
    var category:Category

    init() {
        id = UUID()
        name = ""
        type = ExpenseType.Discretionary
        amount = 0.0
        note = ""
        date = Date.now
        category = Categories().all[0]
    }

    init(id: UUID, name: String, type: ExpenseType, amount: Double, note: String, date: Date, category: Category) {
        self.id = id
        self.name = name
        self.type = type
        self.amount = amount
        self.note = note
        self.date = date
        self.category = category

    }
}

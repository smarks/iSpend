//
//  ExpenseItem.swift
//  iSpend
//
//  Original code created by Paul Hudson on 01/11/2021.
//  Extended by Spencer Marks starting on 07/25/2023
//

import Foundation

class ExpenseItem: Identifiable, Codable, Equatable, ObservableObject {

    var id = UUID()
    var name: String
    var type: ExpenseType
    var amount: Double
    var note: String
    var date: Date
    var category: String
    var discretionaryValue: Double

    static func == (lhs: ExpenseItem, rhs: ExpenseItem) -> Bool {
          // Implement your comparison logic here
          // Compare all the properties that determine if the record has changed
          return lhs.id == rhs.id &&
                 lhs.name == rhs.name &&
                 lhs.amount == rhs.amount &&
                 lhs.category == rhs.category &&
                 lhs.date == rhs.date &&
                 lhs.type == rhs.type &&
                 lhs.discretionaryValue == rhs.discretionaryValue &&
                 lhs.note == rhs.note
      }
    init() {
        id = UUID()
        name = ""
        type = ExpenseType.discretionary
        amount = 0.0
        note = ""
        date = Date.now
        category = Categories.defaultValue
        discretionaryValue = 7.0
    }

    init(id: UUID, name: String, type: ExpenseType, amount: Double, note: String, date: Date, category: Category, discretionaryValue: Double) {
        self.id = id
        self.name = name
        self.type = type
        self.amount = amount
        self.note = note
        self.date = date
        self.category = "None"
        self.discretionaryValue = discretionaryValue
    }
}

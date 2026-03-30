//
//  ExpenseModel.swift
//  iSpend
//
//  Created by Spencer Marks on 8/13/24.
//

import Foundation
import SwiftData

enum ExpenseType: String, Codable, Equatable, CaseIterable {
    case necessary = "Necessary"
    case discretionary = "Discretionary"

    var intValue: Int {
        switch self {
        case .necessary: return 1
        case .discretionary: return 2
        }
    }

    init(from intValue: Int) {
        switch intValue {
        case 1: self = .necessary
        default: self = .discretionary
        }
    }
}

@Model
final class ExpenseModel {
    var id: UUID = UUID()
    var name: String = ""
    var typeMap: Int = NECESSARY
    var amount: Double = 0
    var note: String = ""
    var date: Date = Date()
    var category: String = "None"
    var discretionaryValue: Double = 0

    // Computed from typeMap — not persisted separately.
    var expenseType: ExpenseType {
        get { ExpenseType(from: typeMap) }
        set { typeMap = newValue.intValue }
    }

    init(name: String = "",
         type: Int = NECESSARY,
         amount: Double = 0,
         note: String = "",
         date: Date = Date(),
         category: String = "None",
         discretionaryValue: Double = 0) {

        self.id = UUID()
        self.name = name
        self.typeMap = type
        self.amount = amount
        self.note = note
        self.date = date
        self.category = category
        self.discretionaryValue = discretionaryValue
    }
}

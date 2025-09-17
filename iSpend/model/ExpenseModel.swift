//
//  ExpenseModel.swift
//  iSpend
//
//  Created by Spencer Marks on 8/13/24.
//

import Foundation
import SwiftData
import SwiftUI

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
    var name: String
    var typeMap: Int
    var expenseType: ExpenseType
    var amount: Double
    var note: String
    var date: Date
    var category: String
    var discretionaryValue: Double

    init(name: String = "",
         type: Int = NECESSARY,
         amount: Double = 0,
         note: String = "",
         date: Date = Date(),
         category: String = "None",
         discretionaryValue: Double = 0) {

        self.name = name
        self.typeMap = type
        self.amount = amount
        self.note = note
        self.date = date
        self.category = category
        self.discretionaryValue = discretionaryValue
        self.expenseType = ExpenseType(from: type)
    }
}

//
//  BudgetModel.swift
//  iSpend
//
//  Created by Spencer Marks on 8/27/24.
//

import Foundation
import SwiftData

@Model
final class BudgetModel {
    var id: UUID = UUID()
    var type: Int = NECESSARY
    var amount: Double = 0

    init(type: Int, amount: Double) {
        self.id = UUID()
        self.type = type
        self.amount = amount
    }
}

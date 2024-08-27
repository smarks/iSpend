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
    
    var type:Int // NECESSARY or DISCRETIONARY
    var amount: Double

    init(type: Int, amount: Double) {
        self.type = type
        self.amount = amount
    }
}

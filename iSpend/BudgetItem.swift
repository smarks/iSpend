//
//  BudgetItem.swift
//  iSpend
//
//  Created by Spencer Marks on 3/2/24.
//

import Foundation


struct BudgetItem: Identifiable, Codable, Equatable {
    var id = UUID()
    let name: String
    let type: BudgetType
    var amount: Double

}

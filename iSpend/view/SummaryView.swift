//
//  SummaryView.swift
//  iSpend
//
//  Created by Spencer Marks on 8/24/24.
//

import Foundation
import SwiftUI

struct SummaryView: View {
    @Environment(\.modelContext) private var modelContext
    let expenses: [ExpenseModel]
    let label: String
    let budget: Double

    var total: Double {
        expenses.reduce(0) { $0 + $1.amount }
    }

    var balance: Double {
        total - budget
    }

    var body: some View {
        VStack {
            HStack {
                Text("Total: ").font(.subheadline)
                Text("\(total)")
            }
            HStack {
                Text("Budget: \(budget)")
                Text("Remaining: \(balance)")
            }
        }
    }
}

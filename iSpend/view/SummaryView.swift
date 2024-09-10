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
    let budget: BudgetModel

    var totalExpenses: Double {
        expenses.reduce(0) { $0 + $1.amount }
    }

    var balance: Double {
        budget.amount - totalExpenses
    }

    var balanceColor: Color {
        if balance < 0 {
            return Color.red
        }
        return Color.blue
    }

    var body: some View {
        VStack {
            
            HStack {
                Text("Total:").font(.subheadline)
                Text("\(totalExpenses, format: .localCurrency)").font(.subheadline).foregroundColor(balanceColor).frame(maxWidth: .infinity, alignment: .trailing)
            }.frame(maxWidth: .infinity, alignment: .leading)

            Divider()
            
            HStack {
                Text("Budget:").font(.subheadline).padding(.trailing)
                Text("\(budget.amount, format: .localCurrency)").font(.subheadline).padding(.trailing).frame(maxWidth: .infinity, alignment: .trailing)
            }.frame(maxWidth: .infinity, alignment: .leading)
            
            Divider()
           
            HStack {
                Text("Remaining:").font(.subheadline).padding(.trailing)
                Text("\(balance, format: .localCurrency)").foregroundColor(balanceColor).font(.subheadline).padding(.trailing).frame(maxWidth: .infinity, alignment: .trailing)
            }.frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}

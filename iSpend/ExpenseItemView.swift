//
//  ExpensesItemView.swift
//  iSpend
//
//  Created by Spencer Marks on 5/20/24.
//

import Foundation
import SwiftUI

struct ExpenseItemView: View {
    var title: String
    var amount: String
    var budgetTotal: Double
    var budgetTotalColor: Color
    var backgroundColor: Color
    var expensesItems: [ExpenseItem]

    @State var selectedExpenseItem: ExpenseItem?

    var body: some View {
        HStack {
            Text("Budget:").font(.headline)
            Text(Double(amount) ?? 0, format: .localCurrency)
        }

        HStack {
            Text("Total: ").font(.headline)
            Text(budgetTotal, format: .localCurrency).foregroundColor(budgetTotalColor)
        }

        ForEach(expensesItems) { item in
            HStack {
                Text(dateFormatter.string(from: item.date)).frame(maxWidth: .infinity, alignment: .leading).lineLimit(1)
                Text(item.name).frame(maxWidth: .infinity, alignment: .center).lineLimit(1)
                Text(item.category)
                Text(item.amount, format: .localCurrency).frame(maxWidth: .infinity, alignment: .trailing).lineLimit(1)
            }.frame(maxWidth: .infinity, alignment: .leading)
                .background(backgroundColor(for: item, expenses: expensesItems))
                .onTapGesture {
                    print(item)
                    selectedExpenseItem = item // Set the selected item
                }
        }
    }
    // Helper method to determine the background color for each row
    func backgroundColor(for item: ExpenseItem, expenses: [ExpenseItem]) -> Color {
        if let index = expenses.firstIndex(where: { $0.id == item.id }) {
            return index % 2 == 0 ? Color.white : Color.gray.opacity(0.2)
        } else {
            return Color.white
        }
    }
}
 
 

//
//  ExpenseSection.swift
//  iSpend
//
//  Original code created by Paul Hudson on 01/11/2021.
//  Extended by Spencer Marks starting on 07/25/2023
//

import SwiftUI

struct ItemRow: View {
    var expense: ExpenseItem
    var backgroundColor: Color

    var body: some View {
        HStack {
            Text(expense.name)
            Text(expense.amount, format: .localCurrency)
        }
    }
}

struct ExpenseSection: View {
    let title: String
    let expenses: [ExpenseItem]

    let deleteItems: (IndexSet) -> Void
    let editItems: () -> Void

    let budget: Budget

    var rowNumber: Int = 0

    var total: Double {
        var t: Double = 0.0
        for item in expenses {
            t = t + item.amount
        }
        return t
    }

    var color: Color {
        if Double(budget.amount) ?? 0 >= total {
            return Color.blue
        } else {
            return Color.red
        }
    }

    var backgroundColor: Color {
        if rowNumber % 2 == 0 {
            return Color.white
        } else {
            return Color.gray
        }
    }

    var body: some View {
        Section(title) {
            HStack {
                Text("Budget:").font(.headline)
                Text(Double(budget.amount) ?? 0, format: .localCurrency)
            }

            HStack {
                Text("Total: ").font(.headline)
                Text(total, format: .localCurrency).foregroundColor(color)
            }

          //ScrollView(.vertical) {
                ForEach(expenses) {
                    item in
                        HStack  {
                            Text(item.name)
                            Text(item.amount, format: .localCurrency).padding()
                        }.frame(maxWidth: .infinity, alignment: .leading)
                  
                }
         //  }

            //    .onDelete(perform: deleteItems)
            .onTapGesture(perform: editItems)
        }
    }
}

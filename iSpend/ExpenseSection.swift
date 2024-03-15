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
    let expenseItems: [ExpenseItem]
    @ObservedObject var expenses: Expenses
    var categories:[Category] = Categories.singleInstance.items
    
    @State private var selectedCategory: String?
    @State private var selectedExpenseItem: ExpenseItem? // Track the selected item

    static var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM-dd"
        return formatter
    }()

    let deleteItems: (IndexSet) -> Void

    let budget: Budget

    var rowNumber: Int = 0

    var total: Double {
        /*  var t: Double = 0.0
         for item in expenses {
         t = t + item.amount
         }
         return t
         */
        expenseItems.reduce(0) { $0 + $1.amount }
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
        //  Section() {
        Section(header: Text(title)) {
            HStack {
                Text("Budget:").font(.headline)
                Text(Double(budget.amount) ?? 0, format: .localCurrency)
            }

            HStack {
                Text("Total: ").font(.headline)
                Text(total, format: .localCurrency).foregroundColor(color)
            }

            HStack {
                Text("Date").font(.headline).bold().frame(maxWidth: .infinity, alignment: .leading)
                Text("Description").font(.headline).bold().frame(maxWidth: .infinity, alignment: .center)
                Text("Amount").font(.headline).bold().frame(maxWidth: .infinity, alignment: .trailing)

            }

            ForEach(expenseItems) { item in
                HStack {
                    Text(ExpenseSection.dateFormatter.string(from: item.date)).frame(maxWidth: .infinity, alignment: .leading).lineLimit(1)
                    Text(item.name).frame(maxWidth: .infinity, alignment: .center).lineLimit(1)
                    Text(item.category.name)

                    Text(item.amount, format: .localCurrency).frame(maxWidth: .infinity, alignment: .trailing).lineLimit(1)
                }.frame(maxWidth: .infinity, alignment: .leading)
                    .background(self.backgroundColor(for: item))
                    .onTapGesture {
                        print(item)
                        self.selectedExpenseItem = item // Set the selected item
                    }
            }
            .onDelete(perform: deleteItems)
        }
        .sheet(item: $selectedExpenseItem) { item in
            // Present the sheet for editing
            AddEditExpenseItemView(expenseItem: item)
        }   
    }

    private func dismiss() {
        selectedExpenseItem = nil // Reset the selected item
    }

    // Helper method to determine the background color for each row
    private func backgroundColor(for item: ExpenseItem) -> Color {
        if let index = expenseItems.firstIndex(where: { $0.id == item.id }) {
            return index % 2 == 0 ? Color.white : Color.gray.opacity(0.2)
        } else {
            return Color.white
        }
    }
}

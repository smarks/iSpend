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
    @EnvironmentObject var expenses: Expenses
    @EnvironmentObject var catories: Categories
    
    @State private var selectedCategory: String?
    @State private var selectedExpenseItem: ExpenseItem?
    
   
    var body: some View {
        Text("foo")
    }
    private func dismiss() {
        selectedExpenseItem = nil // Reset the selected item
    }

     
}

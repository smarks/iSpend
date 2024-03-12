//
//  ContentView.swift
//  iSpend
//
//  Original code created by Paul Hudson on 01/11/2021.
//  Extended by Spencer Marks starting on 07/25/2023
//

import SwiftUI

struct ContentView: View {
    @StateObject var expenses = Expenses()
    @StateObject var categories = Categories()

    @State private var showingAddExpense = false
    @State private var showingSettings = false

    @ObservedObject var discretionaryBudget = DiscretionaryBudget()
    @ObservedObject var necessaryBudget = NecessaryBudget()

    let discretionaryTitle = "\(ExpenseType.Discretionary)".capitalized
    let necessaryTitle = "\(ExpenseType.Necessary)".capitalized

    @StateObject var settings = Settings()

    var body: some View {
        NavigationView {
            List {
                ExpenseSection(title: discretionaryTitle, expenseItems: expenses.discretionaryItems, expenses: expenses, categories: categories, deleteItems: removeDiscretionaryItems, budget: discretionaryBudget)

                ExpenseSection(title: necessaryTitle, expenseItems: expenses.necessaryItems, expenses: expenses, categories: categories, deleteItems: removeNecessaryItems, budget: necessaryBudget)
            }
            .navigationTitle("iSpend")
            .toolbar {
                Button {
                    showingAddExpense = true
                } label: {
                    Image(systemName: "plus")
                }
                Button {
                    showingSettings = true
                } label: {
                    Image(systemName: "gear")
                }
            }
            .sheet(isPresented: $showingAddExpense) {
                let newExpenseItem: ExpenseItem = ExpenseItem()
                AddEditExpenseItemView(expenseItem: newExpenseItem, expenses: expenses, categories: categories)
            }
            .sheet(isPresented: $showingSettings) {
                SettingView()
            }

        }.environmentObject(settings)
            .environmentObject(expenses)
    }

    func removeItems(at offsets: IndexSet, in inputArray: [ExpenseItem]) {
        var objectsToDelete = IndexSet()

        for offset in offsets {
            let item = inputArray[offset]

            if let index = expenses.allItems.firstIndex(of: item) {
                objectsToDelete.insert(index)
            }
        }
        // }
        expenses.allItems.remove(atOffsets: objectsToDelete)
    }

    func removeNecessaryItems(at offsets: IndexSet) {
        removeItems(at: offsets, in: expenses.necessaryItems)
    }

    func removeDiscretionaryItems(at offsets: IndexSet) {
        removeItems(at: offsets, in: expenses.discretionaryItems)
    }
}

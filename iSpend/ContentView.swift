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
    @StateObject var settings = Settings()
    
    @StateObject var mediations: Mediations = Mediations()
    @StateObject var categories: Categories = Categories()

    @StateObject var discretionaryBudget = DiscretionaryBudget()
    @StateObject var necessaryBudget = NecessaryBudget()
    
    @State private var showingAddExpense = false
    @State private var showingSettings = false
   
    
    let discretionaryTitle = "\(ExpenseType.Discretionary)".capitalized
    let necessaryTitle = "\(ExpenseType.Necessary)".capitalized

    var body: some View {
        NavigationStack {
            List {
                ExpenseSection(title: discretionaryTitle, expenseItems: expenses.discretionaryItems,  budget: discretionaryBudget)

                ExpenseSection(title: necessaryTitle, expenseItems: expenses.necessaryItems, budget: necessaryBudget)
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
                AddEditExpenseItemView(expenseItem: newExpenseItem)
            }
           
            .sheet(isPresented: $showingSettings) {
                SettingView()
            } 

        }.environmentObject(settings)
            .environmentObject(expenses)
            .environmentObject(discretionaryBudget)
            .environmentObject(necessaryBudget)
            .environmentObject(categories)
            .environmentObject(mediations)
    }
    
  
   
}

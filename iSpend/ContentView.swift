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
                
                ExpenseSection(title: discretionaryTitle, expenseItems: expenses.discretionaryItems, expenses: expenses, deleteItems: removeDiscretionaryItems, editItems: editDiscretionaryItems, budget: discretionaryBudget)
                
                ExpenseSection(title: necessaryTitle, expenseItems: expenses.necessaryItems, expenses: expenses,deleteItems: removeNecessaryItems, editItems: editNecessaryItems, budget: necessaryBudget)
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
                let newExpenseItem:ExpenseItem = ExpenseItem()
                AddView(expenseItem: newExpenseItem, expenses: expenses)
            }
            .sheet(isPresented: $showingSettings) {
                SettingView()
            }

        }.environmentObject(settings)
            .environmentObject(expenses)
    }

    func edit(in item: ExpenseItem) {
        print("edit \(item)")
    }

    func editItems(at offsets: IndexSet, in inputArray: [ExpenseItem]) {
        for offset in offsets {
            let item = inputArray[offset]
            edit(in: item)
        }
    }

    func editNecessaryItems( ) {
      //  editItems(at: offsets, in: expenses.necessaryItems)
        print("e n")
    }

    func editDiscretionaryItems( ) {
       // editItems(at: offsets, in: expenses.discretionaryItems)
        print("e d")
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

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

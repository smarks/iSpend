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
    @StateObject var mediations = Mediations()
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
                ExpenseSection(title: discretionaryTitle, expenses: expenses.necessaryItems, deleteItems: removeNecessaryItems, editItems: editNecessaryItems, budget: discretionaryBudget)
                ExpenseSection(title: necessaryTitle, expenses: expenses.discretionaryItems, deleteItems: removeDiscretionaryItems, editItems: editiscretionaryItems, budget: necessaryBudget)
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
                AddView(expenses: expenses, mediations: mediations)
            }
            .sheet(isPresented: $showingSettings) {
                SettingView()
            }

        }.environmentObject(settings)
            .environmentObject(expenses)
    }

    func editItems(at offsets: IndexSet, in inputArray: [ExpenseItem]) {
        print("edit items")
    }

    func editItems() {
        print("dataChanged")
    }

    func editNecessaryItems() {
        // editItems(at: offsets, in: expenses.discretionaryItems)
        editItems()
    }

    func editiscretionaryItems() {
        // editItems(at: offsets, in: expenses.necessaryItems)
        editItems()
    }

    func removeItems(at offsets: IndexSet, in inputArray: [ExpenseItem]) {
        var objectsToDelete = IndexSet()

        // bug does delete last element  if inputArray.count != 0 {
        // https://github.com/smarks/iSpend/issues/3
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
        removeItems(at: offsets, in: expenses.discretionaryItems)
    }

    func removeDiscretionaryItems(at offsets: IndexSet) {
        removeItems(at: offsets, in: expenses.necessaryItems)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

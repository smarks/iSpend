//
//  ContentView.swift
//  iExpense
//
//  Created by Paul Hudson on 01/11/2021.
//

import SwiftUI

struct ContentView: View {
    @StateObject var expenses = Expenses()
    @State private var showingAddExpense = false
    let discretionaryTitle = "\(ExpenseType.discretionary)".capitalized
    let necessaryTitle = "\(ExpenseType.necessary)".capitalized

    var body: some View {
        NavigationView {
            List {
                ExpenseSection(title: discretionaryTitle, expenses: expenses.businessItems, deleteItems: removeBusinessItems)

                ExpenseSection(title: necessaryTitle, expenses: expenses.personalItems, deleteItems: removePersonalItems)
            }
            .navigationTitle(discretionaryTitle)
            .toolbar {
                Button {
                    showingAddExpense = true
                } label: {
                    Image(systemName: "plus")
                }
            }
            .sheet(isPresented: $showingAddExpense) {
                AddView(expenses: expenses)
            }
        }
    }

    func removeItems(at offsets: IndexSet, in inputArray: [ExpenseItem]) {
        var objectsToDelete = IndexSet()

        for offset in offsets {
            let item = inputArray[offset]

            if let index = expenses.items.firstIndex(of: item) {
                objectsToDelete.insert(index)
            }
        }

        expenses.items.remove(atOffsets: objectsToDelete)
    }

    func removePersonalItems(at offsets: IndexSet) {
        removeItems(at: offsets, in: expenses.personalItems)
    }

    func removeBusinessItems(at offsets: IndexSet) {
        removeItems(at: offsets, in: expenses.businessItems)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

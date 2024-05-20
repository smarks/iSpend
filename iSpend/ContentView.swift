//
//  ContentView.swift
//  Revisit
//
//  Created by Spencer Marks on 5/7/24.
//

import SwiftUI

var dateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateFormat = "MM-dd"
    return formatter
}()

struct ContentView: View {
    @State private var expenses = Expenses()
    @State private var showingAddExpense = false

    let discretionaryBudget: DiscretionaryBudget = DiscretionaryBudget()
    var discretionaryRowNumber: Int = 0
    let necessaryBudget: NecessaryBudget = NecessaryBudget()
    var necessaryRowNumber: Int = 0
    @State var selectedExpenseItem: ExpenseItem?
    @State var showingSettings: Bool = false

    var discretionaryBudgetTotal: Double {
        /*  var t: Double = 0.0
         for item in expenses {
         t = t + item.amount
         }
         return t
         */
        expenses.discretionaryItems.reduce(0) { $0 + $1.amount }
    }

    var necessaryBudgetTotal: Double {
        /*  var t: Double = 0.0
         for item in expenses {
         t = t + item.amount
         }
         return t
         */
        expenses.necessaryItems.reduce(0) { $0 + $1.amount }
    }

    var discretionaryBudgetTotalColor: Color {
        if Double(discretionaryBudget.amount) ?? 0 >= discretionaryBudgetTotal {
            return Color.blue
        } else {
            return Color.red
        }
    }

    var discretionaryBackgroundColor: Color {
        if discretionaryRowNumber % 2 == 0 {
            return Color.white
        } else {
            return Color.gray
        }
    }

    var necessaryBudgetTotalColor: Color {
        if Double(discretionaryBudget.amount) ?? 0 >= discretionaryBudgetTotal {
            return Color.blue
        } else {
            return Color.red
        }
    }

    var necessaryBackgroundColor: Color {
        if necessaryRowNumber % 2 == 0 {
            return Color.white
        } else {
            return Color.gray
        }
    }
    var messageToReflectOn: String {
       let mediations: [String] = Mediations().list
       let index = Int.random(in: 1 ..< mediations.count)
       return mediations[index]
   }
    var body: some View {
        NavigationSplitView {
            List {
                
                Section(header: Text("Necessary").font(.headline)) {
                    ExpenseItemView(title: "Necessary", amount: necessaryBudget.amount,
                                    budgetTotal: necessaryBudgetTotal,
                                    budgetTotalColor: necessaryBudgetTotalColor,
                                    backgroundColor: necessaryBackgroundColor,
                                    expensesItems: expenses.necessaryItems)
                }
                
                Section(header: Text("Discretionary").font(.headline)) {
                    ExpenseItemView(title: "Discretionary", amount: discretionaryBudget.amount,
                                    budgetTotal: discretionaryBudgetTotal,
                                    budgetTotalColor: discretionaryBudgetTotalColor,
                                    backgroundColor: discretionaryBackgroundColor,
                                    expensesItems: expenses.discretionaryItems)
                }

            }.navigationTitle("iSpend")
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
                    AddExpenseView(messageToReflectOn: messageToReflectOn, expenses: expenses)
                }.sheet(isPresented: $showingSettings) {
                    SettingView(settings: Settings(), expenses: expenses)
                }
        } detail: {
            Text("Select an item")
        }
    }

    func removeItems(at offsets: IndexSet) {
        expenses.allItems.remove(atOffsets: offsets)
    }
}

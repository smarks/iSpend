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
 
struct SummaryView: View {
    let totalLabel: String
    let totalAmount: Double
    let spentLabel: String
    let spentAmount: Double
    
    var body: some View {
          HStack {
                Text(totalLabel).font(.headline)
                Text(totalAmount, format: .localCurrency)
                Text(spentLabel) .font(.headline)
                Text(spentAmount, format: .localCurrency) 
            }
        }
}



struct ContentView: View {
    @Environment(\.dismiss) var dismiss
    @State private var showDiscretionary = false
    @State private var showNecessary = false

    @State private var expenses = Expenses()
    @State private var showingAddExpense = false
    @State var selectedExpenseItem: ExpenseItem?
    @State var showingSettings: Bool = false

    @ObservedObject var necessaryBudget: NecessaryBudget = NecessaryBudget()
    @ObservedObject var discretionaryBudget: DiscretionaryBudget = DiscretionaryBudget()

    var discretionaryRowNumber: Int = 0
    var necessaryRowNumber: Int = 0

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
        NavigationStack {
           
            List {
                
                Section(header: Text("Budgets and History").font(.headline).foregroundStyle(.blue)) {
                    VStack(alignment: .leading) {
                        SummaryView(totalLabel: "Total Budgeted:", totalAmount: Double(necessaryBudget.amount + discretionaryBudget.amount) ?? 0, spentLabel: "Spent: ", spentAmount: necessaryBudgetTotal + discretionaryBudgetTotal)
                        
                        SummaryView(totalLabel: "Necessary Budgeted:", totalAmount: Double(necessaryBudget.amount) ?? 0, spentLabel: "Spent: ", spentAmount: necessaryBudgetTotal)
                      
                        SummaryView(totalLabel: "Discretionary Budgeted:", totalAmount: Double(discretionaryBudget.amount) ?? 0, spentLabel: "Spent: ", spentAmount: discretionaryBudgetTotal)
    
                        }
                       
                        HStack { Text("Show: ")
                            .font(.subheadline)
                            .foregroundColor(.black)
                            CheckboxView(isChecked: $showDiscretionary, label: "discretionary") .font(.subheadline)
                                .foregroundColor(.black).padding()
                            CheckboxView(isChecked: $showNecessary, label: "Necessary") .font(.subheadline)
                                .foregroundColor(.black).padding(.horizontal)
                        }

                        
                    }
            
                /*
                Section(header: Text("All").font(.headline).foregroundStyle(.blue)) {
                    ExpenseItemView(expenses: expenses, title: "All", amount: necessaryBudget.amount + discretionaryBudget.amount,
                                    budgetTotal: necessaryBudgetTotal + necessaryBudgetTotal,
                                    budgetTotalColor: necessaryBudgetTotalColor,
                                    backgroundColor: necessaryBackgroundColor,
                                    expensesItems: expenses.allItems)
                }
                Section(header: Text("Necessary").font(.headline).foregroundStyle(.blue)) {
                    ExpenseItemView(expenses: expenses, title: "Necessary", amount: necessaryBudget.amount,
                                    budgetTotal: necessaryBudgetTotal,
                                    budgetTotalColor: necessaryBudgetTotalColor,
                                    backgroundColor: necessaryBackgroundColor,
                                    expensesItems: expenses.necessaryItems)
                }

                Section(header: Text("Discretionary").font(.headline).foregroundStyle(.blue)) {
                    ExpenseItemView(expenses: expenses, title: "Discretionary", amount: discretionaryBudget.amount,
                                    budgetTotal: discretionaryBudgetTotal,
                                    budgetTotalColor: discretionaryBudgetTotalColor,
                                    backgroundColor: discretionaryBackgroundColor,
                                    expensesItems: expenses.discretionaryItems)
                }*/

            }.navigationTitle("iSpend")
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button {
                            showingAddExpense = true
                        } label: {
                            Image(systemName: "plus")
                        }
                    }
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button {
                            showingSettings = true
                        } label: {
                            Image(systemName: "gear")
                        }
                    }
                }.sheet(isPresented: $showingAddExpense) {
                    AddExpenseView(messageToReflectOn: messageToReflectOn, expenses: expenses)
                }.sheet(isPresented: $showingSettings) {
                    SettingView(settings: Settings(), expenses: expenses)
                }
        }
    }

    func delete(at offsets: IndexSet) {
        // delete the objects here
    }

    func removeItems(at offsets: IndexSet) {
        expenses.allItems.remove(atOffsets: offsets)
    }
}

struct RadioButtonView: View {
    let id: String
    let label: String
    let isSelected: Bool
    let callback: (String) -> Void

    var body: some View {
        Button(action: {
            self.callback(self.id)
        }) {
            HStack {
                Image(systemName: self.isSelected ? "largecircle.fill.circle" : "circle")
                    .renderingMode(.original)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 18, height: 18)
                Text(label)
            }
        }
        .foregroundColor(.primary)
    }
}

struct RadioButtonGroup: View {
    let items: [String]
    @State private var selectedId: String
    let callback: (String) -> Void

    init(items: [String], selectedId: String, callback: @escaping (String) -> Void) {
        self.items = items
        _selectedId = State(initialValue: selectedId)
        self.callback = callback
    }

    var body: some View {
        HStack {
            ForEach(items, id: \.self) { item in
                RadioButtonView(id: item, label: item, isSelected: self.selectedId == item) { selected in
                    self.selectedId = selected
                    self.callback(selected)
                }
            }
        }
    }
}

struct CheckboxView: View {
    @Binding var isChecked: Bool
    let label: String

    var body: some View {
        Button(action: {
            self.isChecked.toggle()
        }) {
            HStack {
                Image(systemName: self.isChecked ? "checkmark.square.fill" : "square")
                    .renderingMode(.original)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 18, height: 18)
                Text(label)
            }
        }
        .foregroundColor(.primary)
    }
}

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
    
    @State private var selectedExpenseItem: ExpenseItem?
    
    let discretionaryTitle = "\(ExpenseType.Discretionary)".capitalized
    let necessaryTitle = "\(ExpenseType.Necessary)".capitalized
    
    static var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM-dd"
        return formatter
    }()
    
    var rowNumber: Int = 0
    
    var discretionaryTotal: Double {
        expenses.discretionaryItems.reduce(0) { $0 + $1.amount }
    }
    
    var necessaryTotal: Double {
        expenses.necessaryItems.reduce(0) { $0 + $1.amount }
    }
    
    var discretionaryBudgetColor: Color {
        if Double(discretionaryBudget.amount) ?? 0 >= discretionaryTotal {
            return Color.blue
        } else {
            return Color.red
        }
    }
    
    var necessaryBudgettColor: Color {
        if Double(necessaryBudget.amount) ?? 0 >= necessaryTotal {
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
        
        NavigationStack {
            VStack {
                Text(discretionaryTitle)
                Text("Budget:").font(.headline)
                Text(Double(discretionaryBudget.amount) ?? 0, format: .localCurrency)
                
                ForEach(expenses.discretionaryItems) { item in
                    HStack {
                        Text(ContentView.dateFormatter.string(from: item.date)).frame(maxWidth: .infinity, alignment: .leading).lineLimit(1)
                        Text(item.name).frame(maxWidth: .infinity, alignment: .center).lineLimit(1)
                        Text(item.category.name)
                        Text(item.amount, format: .localCurrency).frame(maxWidth: .infinity, alignment: .trailing).lineLimit(1)
                    }.frame(maxWidth: .infinity, alignment: .leading)
                        .background(self.backgroundColor(for: item, expenseItems: expenses.discretionaryItems))
                        .onTapGesture {
                            print(item)
                            selectedExpenseItem = item
                        }
                }
                
            }.toolbar {
                
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
            
            
            
        
        }.sheet(isPresented: $showingSettings) {
            SettingView().environmentObject(settings)
                .environmentObject(expenses)
                .environmentObject(discretionaryBudget)
                .environmentObject(necessaryBudget)
                .environmentObject(categories)
                .environmentObject(mediations)
            
        }.sheet(isPresented: $showingAddExpense) {
            AddEditExpenseItemView(expenseItem: selectedExpenseItem ??  ExpenseItem()).environmentObject(settings)
                .environmentObject(expenses)
                .environmentObject(discretionaryBudget)
                .environmentObject(necessaryBudget)
                .environmentObject(categories)
                .environmentObject(mediations)
        }
    }

    
    // Helper method to determine the background color for each row
    private func backgroundColor(for item: ExpenseItem, expenseItems: [ExpenseItem]) -> Color {
        if let index = expenseItems.firstIndex(where: { $0.id == item.id }) {
            return index % 2 == 0 ? Color.white : Color.gray.opacity(0.2)
        } else {
            return Color.white
        }
    }

     
    private func addItem() {
        var expenseItem:ExpenseItem = ExpenseItem(id: UUID(), name: "name", type: ExpenseType.Discretionary, amount: 0.0, note: "Spencer", date: Date(), category: Categories.defaultValue, discretionaryValue: 1.9)
        expenses.allItems.append(expenseItem)
         
    }

    private func deleteItems(offsets: IndexSet) {
    }
}

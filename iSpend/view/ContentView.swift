//
//  ContentView.swift
//
//
//  Created by Spencer Marks on 5/7/24.
//

import SwiftData
import SwiftUI

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext

    @Query(filter: #Predicate<ExpenseModel> { expense in expense.typeMap == NECESSARY }, sort: [SortDescriptor(\ExpenseModel.date)])
    private var necessaryExpenses: [ExpenseModel]

    @Query(filter: #Predicate<ExpenseModel> { expense in expense.typeMap == DISCRETIONARY }, sort: [SortDescriptor(\ExpenseModel.date)])
    private var discretionaryExpenses: [ExpenseModel]

    @Query(filter: #Predicate<BudgetModel> { budget in budget.type == NECESSARY })
    private var necessaryBudgets: [BudgetModel]

    @Query(filter: #Predicate<BudgetModel> { budget in budget.type == DISCRETIONARY })
    private var discretionaryBudgets: [BudgetModel]

    // These computed properties are read-only — budget creation happens in iSpendApp on first launch.
    private var necessaryBudget: BudgetModel {
        necessaryBudgets.first ?? BudgetModel(type: NECESSARY, amount: 0)
    }

    private var discretionaryBudget: BudgetModel {
        discretionaryBudgets.first ?? BudgetModel(type: DISCRETIONARY, amount: 0)
    }

    @State private var showingAddEntry: Bool = false
    @State private var showingSettings: Bool = false
    @State private var selectedItem: ExpenseModel?

    var body: some View {
        NavigationStack {
            List {
                Section(header: Text("Necessary Expenses")) {
                    SummaryView(expenses: necessaryExpenses, label: "Necessary", budget: necessaryBudget)
                    Heading()
                    ForEach(necessaryExpenses) { item in
                        ExpenseModelView(expenseModel: item)
                            .onTapGesture(count: 2) {
                                selectedItem = item
                                showingAddEntry = true
                            }
                    }.onDelete { offsets in delete(from: necessaryExpenses, at: offsets) }
                }
                Section(header: Text("Discretionary Expenses")) {
                    SummaryView(expenses: discretionaryExpenses, label: "Discretionary", budget: discretionaryBudget)
                    Heading()
                    ForEach(discretionaryExpenses) { item in
                        ExpenseModelView(expenseModel: item)
                            .onTapGesture(count: 2) {
                                selectedItem = item
                                showingAddEntry = true
                            }
                    }.onDelete { offsets in delete(from: discretionaryExpenses, at: offsets) }
                }
            }
            .navigationTitle("iSpend")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showingAddEntry = true
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
            }
            .sheet(isPresented: $showingAddEntry, onDismiss: { selectedItem = nil }) {
                let isNew = selectedItem == nil
                let item = selectedItem ?? ExpenseModel()
                ExpenseModelViewEditor(expenseModel: item, isNew: isNew)
                    .environment(\.modelContext, modelContext)
            }
            .sheet(isPresented: $showingSettings) {
                SettingsView()
                    .environment(\.modelContext, modelContext)
            }
        }
    }

    private func delete(from expenses: [ExpenseModel], at offsets: IndexSet) {
        for index in offsets {
            modelContext.delete(expenses[index])
        }
    }
}

struct Heading: View {
    var body: some View {
        HStack {
            Text("Date").fontWeight(.semibold).font(.subheadline).frame(maxWidth: .infinity, alignment: .leading)
            Text("Name").fontWeight(.semibold).font(.subheadline).frame(maxWidth: .infinity, alignment: .leading)
            Text("Category").fontWeight(.semibold).font(.subheadline).frame(maxWidth: .infinity, alignment: .leading)
            Text("Amount").fontWeight(.semibold).font(.subheadline).frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}

//
//  ContentView.swift
//
//
//  Created by Spencer Marks on 5/7/24.
//

import SwiftData
import SwiftUI

struct ContentView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.modelContext) private var modelContext

    @Query(filter: #Predicate<ExpenseModel> { expense in expense.typeMap == NECESSARY }, sort: [SortDescriptor(\ExpenseModel.date)])
    private var necessaryExpenses: [ExpenseModel]

    @Query(filter: #Predicate<ExpenseModel> { expense in expense.typeMap == DISCRETIONARY }, sort: [SortDescriptor(\ExpenseModel.date)])
    private var discretionaryExpenses: [ExpenseModel]

    @Query(filter: #Predicate<BudgetModel> { budget in budget.type == NECESSARY })
    private var necessaryBudgets: [BudgetModel]

    private var necessaryBudget: BudgetModel {
        if necessaryBudgets.isEmpty {
            let budgetModel: BudgetModel = BudgetModel(type: NECESSARY, amount: 0)
            modelContext.insert(budgetModel)
            return budgetModel
        } else {
            return necessaryBudgets[0]
        }
    }

    @Query(filter: #Predicate<BudgetModel> { budget in budget.type == DISCRETIONARY })
    private var discretionaryBudgets: [BudgetModel]

    private var discretionaryBudget: BudgetModel {
        if discretionaryBudgets.isEmpty {
            let budgetModel: BudgetModel = BudgetModel(type: DISCRETIONARY, amount: 0)
            modelContext.insert(BudgetModel(type: DISCRETIONARY, amount: 0))
            return budgetModel
        } else {
            return discretionaryBudgets[0]
        }
    }

    @State var showingAddEntry: Bool = false
    @State var showingSettings: Bool = false
    @State var selectedItem: ExpenseModel?

    var body: some View {
        NavigationStack {
            List {
                Section(header: Text("Necessary Expenses")) {
                    SummaryView(expenses: necessaryExpenses, label: "Necessary", budget: necessaryBudget)
                    Heading()
                    ForEach(necessaryExpenses) { item in
                        ExpenseModelView(expenseModel: item)
                            .onTapGesture(count: 2) {
                                self.selectedItem = item
                                self.showingAddEntry = true
                                print("selected item: \(selectedItem?.name ?? "tear")")
                            }
                    }.onDelete(perform: delete)
                }
                Section(header: Text("Discretionary Expenses")) {
                    SummaryView(expenses: discretionaryExpenses, label: "Discretionary", budget: discretionaryBudget)
                    Heading()
                    ForEach(discretionaryExpenses) { item in
                        ExpenseModelView(expenseModel: item)
                            .onTapGesture(count: 2) {
                                self.selectedItem = item
                                self.showingAddEntry = true
                                print("selected item: \(selectedItem?.name ?? "tear")")
                                print(item)
                            }
                    }.onDelete(perform: deleteDiscretionary)
                }
            }.navigationTitle("iSpend")
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
                }.sheet(isPresented: $showingAddEntry) {
                    let item: ExpenseModel = self.selectedItem ?? ExpenseModel()
                    ExpenseModelViewEditor(expenseModel: item)
                }.sheet(isPresented: $showingSettings) {
                    SettingsView()
                }
        }
    }

    func delete(at offsets: IndexSet) {
        modelContext.delete(necessaryExpenses[offsets.count - 1])
    }

    func deleteDiscretionary(at offsets: IndexSet) {
        modelContext.delete(discretionaryExpenses[offsets.count - 1])
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

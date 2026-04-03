//
//  ContentView.swift
//
//
//  Created by Spencer Marks on 5/7/24.
//

import SwiftData
import SwiftUI

enum SortField {
    case date, name, category, amount
}

struct SortState {
    var field: SortField = .date
    var ascending: Bool = false  // default: newest first
}

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

    private var necessaryBudget: BudgetModel {
        necessaryBudgets.first ?? BudgetModel(type: NECESSARY, amount: 0)
    }

    private var discretionaryBudget: BudgetModel {
        discretionaryBudgets.first ?? BudgetModel(type: DISCRETIONARY, amount: 0)
    }

    private var necessaryExpensesInPeriod: [ExpenseModel] {
        let start = necessaryBudget.currentPeriodStart
        let end = necessaryBudget.currentPeriodEnd
        return necessaryExpenses.filter { $0.date >= start && $0.date < end }
    }

    private var discretionaryExpensesInPeriod: [ExpenseModel] {
        let start = discretionaryBudget.currentPeriodStart
        let end = discretionaryBudget.currentPeriodEnd
        return discretionaryExpenses.filter { $0.date >= start && $0.date < end }
    }

    private var necessaryPeriodIDs: Set<UUID> {
        Set(necessaryExpensesInPeriod.map(\.id))
    }

    private var discretionaryPeriodIDs: Set<UUID> {
        Set(discretionaryExpensesInPeriod.map(\.id))
    }

    @State private var showingAddEntry: Bool = false
    @State private var showingSettings: Bool = false
    @State private var selectedItem: ExpenseModel?
    @State private var necessarySort = SortState()
    @State private var discretionarySort = SortState()
    @State private var newExpenseType: Int = NECESSARY

    private func sorted(_ expenses: [ExpenseModel], by state: SortState) -> [ExpenseModel] {
        switch state.field {
        case .date:     return expenses.sorted { state.ascending ? $0.date < $1.date : $0.date > $1.date }
        case .name:     return expenses.sorted { state.ascending ? $0.name.localizedCompare($1.name) == .orderedAscending : $0.name.localizedCompare($1.name) == .orderedDescending }
        case .category: return expenses.sorted { state.ascending ? $0.category.localizedCompare($1.category) == .orderedAscending : $0.category.localizedCompare($1.category) == .orderedDescending }
        case .amount:   return expenses.sorted { state.ascending ? $0.amount < $1.amount : $0.amount > $1.amount }
        }
    }

    var body: some View {
        NavigationStack {
            List {
                Section(header: sectionHeader("Overview", type: NECESSARY).allowsHitTesting(false)) {
                    OverviewView(
                        necessaryExpenses: necessaryExpenses,
                        discretionaryExpenses: discretionaryExpenses,
                        necessaryExpensesInPeriod: necessaryExpensesInPeriod,
                        discretionaryExpensesInPeriod: discretionaryExpensesInPeriod
                    )
                }

                Section(header: sectionHeader("Necessary Expenses", type: NECESSARY)) {
                    SummaryView(expenses: necessaryExpensesInPeriod, label: "Necessary", budget: necessaryBudget)
                    Heading(sortState: $necessarySort)
                    if necessaryExpenses.isEmpty {
                        Text("No expenses yet")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .frame(maxWidth: .infinity, alignment: .center)
                            .padding(.vertical, 4)
                    } else {
                        ForEach(sorted(necessaryExpenses, by: necessarySort)) { item in
                            ExpenseModelView(
                                expenseModel: item,
                                isInPeriod: necessaryPeriodIDs.contains(item.id)
                            )
                            .onTapGesture(count: 2) {
                                selectedItem = item
                                showingAddEntry = true
                            }
                        }.onDelete { offsets in delete(from: sorted(necessaryExpenses, by: necessarySort), at: offsets) }
                    }
                }

                Section(header: sectionHeader("Discretionary Expenses", type: DISCRETIONARY)) {
                    SummaryView(expenses: discretionaryExpensesInPeriod, label: "Discretionary", budget: discretionaryBudget)
                    Heading(sortState: $discretionarySort)
                    if discretionaryExpenses.isEmpty {
                        Text("No expenses yet")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .frame(maxWidth: .infinity, alignment: .center)
                            .padding(.vertical, 4)
                    } else {
                        ForEach(sorted(discretionaryExpenses, by: discretionarySort)) { item in
                            ExpenseModelView(
                                expenseModel: item,
                                isInPeriod: discretionaryPeriodIDs.contains(item.id)
                            )
                            .onTapGesture(count: 2) {
                                selectedItem = item
                                showingAddEntry = true
                            }
                        }.onDelete { offsets in delete(from: sorted(discretionaryExpenses, by: discretionarySort), at: offsets) }
                    }
                }
            }
            .navigationTitle("iSpend")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        newExpenseType = NECESSARY
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
                let item = selectedItem ?? ExpenseModel(type: newExpenseType)
                ExpenseModelViewEditor(expenseModel: item, isNew: isNew)
                    .environment(\.modelContext, modelContext)
            }
            .sheet(isPresented: $showingSettings) {
                SettingsView()
                    .environment(\.modelContext, modelContext)
            }
        }
    }

    private func sectionHeader(_ title: String, type: Int) -> some View {
        HStack {
            Text(title)
                .font(.headline)
                .foregroundStyle(.primary)
                .textCase(nil)
            Spacer()
            Button {
                newExpenseType = type
                showingAddEntry = true
            } label: {
                Image(systemName: "plus")
                    .font(.caption)
                    .fontWeight(.bold)
            }
            .buttonStyle(.plain)
            .foregroundStyle(.secondary)
        }
    }

    private func delete(from expenses: [ExpenseModel], at offsets: IndexSet) {
        for index in offsets {
            modelContext.delete(expenses[index])
        }
    }
}

struct Heading: View {
    @Binding var sortState: SortState

    var body: some View {
        HStack {
            columnHeader("Date",     field: .date)
            columnHeader("Name",     field: .name)
            columnHeader("Category", field: .category)
            columnHeader("Amount",   field: .amount)
        }
    }

    private func columnHeader(_ title: String, field: SortField) -> some View {
        Button {
            if sortState.field == field {
                sortState.ascending.toggle()
            } else {
                sortState = SortState(field: field, ascending: field == .amount ? false : true)
            }
        } label: {
            HStack(spacing: 2) {
                Text(title)
                    .fontWeight(.semibold)
                    .font(.subheadline)
                if sortState.field == field {
                    Image(systemName: sortState.ascending ? "chevron.up" : "chevron.down")
                        .font(.caption2)
                        .fontWeight(.bold)
                }
            }
            .foregroundStyle(.primary)
        }
        .buttonStyle(.plain)
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

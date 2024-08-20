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

    @Query(filter: #Predicate<ExpenseModel> { expense in expense.type == NECESSARY }, sort: [SortDescriptor(\ExpenseModel.date)])
    private var necessaryExpenses: [ExpenseModel]

    @Query(filter: #Predicate<ExpenseModel> { expense in expense.type == DISCRETIONARY }, sort: [SortDescriptor(\ExpenseModel.date)])
    private var discretionaryExpenses: [ExpenseModel]

    @State var showingAddEntry: Bool = false
    @State var showingSettings: Bool = false
    @State var selectedItem: ExpenseModel?

    var body: some View {
        NavigationStack {
            List {
                Section(header: Text("Necessary Expenses")) {
                    ForEach(necessaryExpenses) { item in
                        ExpenseModelView(expenseModel: item)
                            .onTapGesture(count: 1) {
                                selectedItem = item
                                showingAddEntry = true
                            }
                    }.onDelete(perform: delete)
                }
                Section(header: Text("Discretionary Expenses")) {
                    ForEach(discretionaryExpenses) { item in
                        ExpenseModelView(expenseModel: item)
                            .onTapGesture(count: 1) {
                                selectedItem = item
                                showingAddEntry = true
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
                    let item: ExpenseModel = selectedItem ?? ExpenseModel()
                    ExpenseModelViewEditor(expenseModel: item)
                }.sheet(isPresented: $showingSettings) {
                    // SettingView(settings: Settings())
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

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
                    SummaryView(expenses: necessaryExpenses, label: "Necessary", budget: 0)
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
                    SummaryView(expenses: discretionaryExpenses,label: "Discretionary", budget: 0)
                    ForEach(discretionaryExpenses) { item in
                        ExpenseModelView(expenseModel: item)
                            .onTapGesture(count: 2 ){
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

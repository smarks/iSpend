//
//  AddEditExpenseItemView.swift
//  iSpend
//
//  Created by Spencer Marks and then rewritten by perplexity.ai/
//
// This view allows the user to add or edit expense items.

import SwiftUI

struct AddEditExpenseItemView: View {
 
    @ObservedObject var expenseItem: ExpenseItem
  
    @State var originalExpenseItem: ExpenseItem
    @State private var stringAmount: String = ""

    @EnvironmentObject private var expenses: Expenses
    @Environment(\.dismiss) private var dismiss

    @State  var categories: [String] = Categories().list
    @State  var mediations: [String] = Mediations().list
    
    let gradient = Gradient(colors: [.green, .yellow, .orange, .red])

    let types = [ExpenseType.necessary, ExpenseType.discretionary]

    // If expense record is incomplete or hasn't changed, disable save button.
    private var disableSave: Bool {
        expenseItem.name.isEmpty
        ||
        expenseItem == originalExpenseItem
        || 
        expenseItem.amount <= 0.0
    
    }

    private var messageToReflectOn: String {
        let index = Int.random(in: 1..<mediations.count)
        return mediations[index]
    }

    private var viewTitle: String {
        if  expenseItem.name.isEmpty {
            return "Record a New Expense"
        } else {
            return "Edit \(expenseItem.name)"
        }
    }
    

    var body: some View {
        NavigationView {
            Form {
                reflectionSection
                detailsSection
            }
            .navigationTitle(viewTitle)
            .toolbar {
                cancelButton
                saveButton
            }
        }
        .onAppear {
            // Initialize stringAmount with the current amount when the view appears
            stringAmount = String(format: "%.2f", expenseItem.amount)
        }
    }

    private var reflectionSection: some View {
        Section {
            Text(messageToReflectOn)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                .italic()
        } header: {
            Text("Reflection")
        }
    }

    private var detailsSection: some View {
        Section {
            TextField("Name", text: $expenseItem.name)
            typePicker
            NumericTextField(numericText: $stringAmount, amountDouble: $expenseItem.amount)
            TextField("Notes", text: $expenseItem.note)
            categoryPicker
            datePicker
        } header: {
            Text("Details")
        }
    }

    private var typePicker: some View {
        Picker("Type", selection: $expenseItem.type) {
            ForEach(types, id: \.self) { type in
                Text(type.rawValue)
            }
        }
    }

    private var categoryPicker: some View {
        Picker("Category", selection: $expenseItem.category) {
            ForEach(categories, id: \.self) { category in
                Text(category).tag(category)
            }
        }
        .pickerStyle(MenuPickerStyle())
    }

    private var datePicker: some View {
        DatePicker("Date", selection: $expenseItem.date, in: ...Date())
    }

    private var cancelButton: some ToolbarContent {
        ToolbarItem(placement: .navigationBarLeading) {
            Button("Cancel") {
                dismiss()
            }
        }
    }

    private var saveButton: some ToolbarContent {
        ToolbarItem(placement: .navigationBarTrailing) {
            Button("Save") {
                saveExpense()
                dismiss()
            }
            .disabled(disableSave)
        }
    }

    private func saveExpense() {
        if let index = expenses.allItems.firstIndex(where: { $0.id == expenseItem.id }) {
            expenses.allItems[index] = expenseItem
        } else {
            expenses.allItems.append(expenseItem)
        }
    }
}



import SwiftUI
//
//  AddEditExpenseItemView.swift
//  iSpend
//
//  Created by Spencer Marks
//
// This view allows the user to add or edit expense items.

struct AddEditExpenseItemView: View {
    @State var expenseItem: ExpenseItem
    @State var originalExpenseItem: ExpenseItem
    @State private var stringAmount: String = ""

    @EnvironmentObject() var expenses: Expenses

    var categories:[String] = Categories().list

    @Environment(\.dismiss) var dismiss

    let types = [ExpenseType.Necessary, ExpenseType.Discretionary]

    // if expense record is incomplete or hasn't changed, disable save button.
    var disableSave: Bool {
        expenseItem.name.isEmpty || originalExpenseItem == expenseItem || expenseItem.amount == 0.0
    }

    var mediations: [String] = Mediations().list

    var messageToReflectOn: String {
        let index = Int.random(in: 1 ..< mediations.count)
        return mediations[index]
    }

    let gradient = Gradient(colors: [.green, .yellow, .orange, .red])

    var body: some View {
        NavigationView {
            Form {
                Text(messageToReflectOn)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                    .italic()

                TextField("Name", text: $expenseItem.name)
                Picker("Type", selection: $expenseItem.type) {
                    ForEach(types, id: \.self) {
                        let label = "\($0)"
                        Text(label)
                    }
                }.onChange(of: expenseItem.discretionaryValue) { _, _ in
                    if expenseItem.discretionaryValue < 2 {
                        expenseItem.type = ExpenseType.Necessary
                    } else {
                        expenseItem.type = ExpenseType.Discretionary
                    }
                }.onChange(of: expenseItem.type) { _, _ in
                    if expenseItem.type == ExpenseType.Discretionary {
                        expenseItem.discretionaryValue = 7
                    } else {
                        expenseItem.discretionaryValue = 1
                    }
                }

                ZStack {
                    LinearGradient(gradient: gradient, startPoint: .leading, endPoint: .trailing)
                        .mask(Slider(value: $expenseItem.discretionaryValue, in: 1 ... 7, step: 1))

                    Slider(value: $expenseItem.discretionaryValue, in: 1 ... 7, step: 1)
                        .opacity(0.05) // Allows sliding
                }

                //  stringAmount = String(expenseItem.amount)
                NumericTextField(numericText: $stringAmount, amountDouble: $expenseItem.amount)

                TextField("Notes", text: $expenseItem.note)

                Picker("Category", selection: $expenseItem.category) {
                    ForEach(categories, id: \.self) { category in
                        Text(category).tag(category)
                    }
                }
                .onChange(of: expenseItem.category) {
                    if let newCategory = categories.first(where: { $0 == expenseItem.category }) {
                        expenseItem.category = newCategory
                    }
                }
                .pickerStyle(MenuPickerStyle())

                DatePicker(selection: $expenseItem.date, in: ...Date(), displayedComponents: .date) {
                    Text("Date")
                }
            }
            .navigationTitle("Record a New Expense")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        if let index = expenses.allItems.firstIndex(where: { $0.id == expenseItem.id }) {
                            expenses.allItems[index] = expenseItem
                        } else {
                            expenses.allItems.append(expenseItem)
                        }
                        dismiss()
                    }
                    .disabled(disableSave)
                }
            }
        }
    }
}

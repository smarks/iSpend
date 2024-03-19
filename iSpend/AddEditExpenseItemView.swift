import SwiftUI
//
//  AddEditExpenseItemView.swift
//  iSpend
//
//  Created by Spencer Marks
//
// This view allows the user to add or edit expense items.

struct AddEditExpenseItemView: View {
    @State private var expenseItem: ExpenseItem
    @State private var stringAmount: String = ""
    @State private var selectedCategoryId: UUID
    @State private var originalExpenseItem: ExpenseItem

    @EnvironmentObject() var expenses: Expenses

    @ObservedObject var categories: Categories = Categories.singleInstance
    @ObservedObject var mediations: Mediations = Mediations.singleInstance

    @Environment(\.dismiss) var dismiss

    let types = [ExpenseType.Necessary, ExpenseType.Discretionary]

    // if expense record is incomplete or hasn't changed, disable save button.
    var disableSave: Bool {
        expenseItem.name.isEmpty || originalExpenseItem == expenseItem || expenseItem.amount == 0.0
    }

    var messageToReflectOn: String {
        let index = Int.random(in: 1 ..< mediations.items.count)
        return mediations.items[index].name
    }

    let gradient = Gradient(colors: [.green, .yellow, .orange, .red])

    init(expenseItem: ExpenseItem) {
        _expenseItem = State(initialValue: expenseItem)
        _originalExpenseItem = State(initialValue: expenseItem)

        selectedCategoryId = expenseItem.id

        // Find the category in categories.all that matches expenseItem.category
        if let existingCategory = categories.items.first(where: { $0.id == expenseItem.category.id }) {
            // If found, use its ID as the initial value for selectedCategoryId
            _selectedCategoryId = State(initialValue: existingCategory.id)
        } else {
            // If not found, use the default category's ID as the initial value
            _selectedCategoryId = State(initialValue: categories.defaultValue.id)
        }
        
    }

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

                Picker("Category", selection: $selectedCategoryId) {
                    ForEach(categories.items, id: \.id) { category in
                        Text(category.name).tag(category.id)
                    }
                }
                .onChange(of: selectedCategoryId) {
                    if let newCategory = categories.items.first(where: { $0.id == selectedCategoryId }) {
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

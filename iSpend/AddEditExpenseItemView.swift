import SwiftUI
//
//  AddEditExpenseItemView.swift
//  iSpend
//
//  Created by Spencer Marks
//
// This view allows the user to add or edit expense items.

struct AddEditExpenseItemView: View {
    @StateObject private var mediations = Mediations()
    @State private var expenseItem: ExpenseItem
    @State private var stringAmount: String = ""
    @State private var sliderValue: Double = .zero
    @State private var selectedCategoryId: UUID
    @State private var originalExpenseItem: ExpenseItem

    @ObservedObject var expenses: Expenses
    @ObservedObject var categories: Categories

    @Environment(\.dismiss) var dismiss
    
    let types = [ExpenseType.Necessary, ExpenseType.Discretionary]
    
    // if expense record is incomplete, disable save button.
    var disableSave: Bool {
        expenseItem.name.isEmpty || originalExpenseItem == expenseItem
    }

    var messageToReflectOn: String {
        let index = Int.random(in: 1 ..< mediations.items.count)
        return mediations.items[index]
    }

    let gradient = Gradient(colors: [.green, .yellow, .orange, .red])

    // Initialize the selectedCategoryId with the category ID of the expenseItem
    init(expenseItem: ExpenseItem, expenses: Expenses, categories: Categories) {
        _expenseItem = State(initialValue: expenseItem)
        _originalExpenseItem = State(initialValue: expenseItem)  
        self.expenses = expenses
        self.categories = categories

        // Find the category in categories.all that matches expenseItem.category
        if let existingCategory = categories.all.first(where: { $0.id == expenseItem.category.id }) {
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

                ZStack {
                    LinearGradient(gradient: gradient, startPoint: .leading, endPoint: .trailing)
                        .mask(Slider(value: $sliderValue, in: 1 ... 7, step: 1))

                    Slider(value: $sliderValue, in: 1 ... 7, step: 1)
                        .opacity(0.05) // Allows sliding
                }
                .onChange(of: sliderValue) { _, _ in
                    if sliderValue < 2 {
                        expenseItem.type = ExpenseType.Necessary
                    } else {
                        expenseItem.type = ExpenseType.Discretionary
                    }
                }
                
                NumericTextField(numericText: $stringAmount, amountDouble: $expenseItem.amount)

                TextField("Notes", text: $expenseItem.note)

                Picker("Category", selection: $selectedCategoryId) {
                    ForEach(categories.all, id: \.id) { category in
                        Text(category.name).tag(category.id)
                    }
                }
                .onChange(of: selectedCategoryId) { _, newValue in
                    if let newCategory = categories.all.first(where: { $0.id == newValue }) {
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

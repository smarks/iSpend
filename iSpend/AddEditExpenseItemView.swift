import SwiftUI

struct AddEditExpenseItemView: View {
    @StateObject var mediations = Mediations()

    @State var expenseItem: ExpenseItem

    @ObservedObject var expenses: Expenses
    @ObservedObject var categories: Categories

    @Environment(\.dismiss) var dismiss
    @State var stringAmount: String = ""
    @State private var sliderValue: Double = .zero

    let types = [ExpenseType.Necessary, ExpenseType.Discretionary]

    var disableSave: Bool {
        expenseItem.name.isEmpty
    }

    var messageToReflectOn: String {
        let index = Int.random(in: 1 ..< mediations.items.count)
        return mediations.items[index]
    }
    let gradient = Gradient(colors: [.green, .yellow, .orange, .red])

    var body: some View {
        NavigationView {
            Form {
                Text(messageToReflectOn)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                    .italic()

                TextField("Name", text: $expenseItem.name)
                Picker("Category", selection: $expenseItem.category) {
                    ForEach(categories.all, id: \.id) { category in
                        Text(category.name).tag(category)
                    }
                }


                ZStack {
                    LinearGradient(gradient: gradient, startPoint: .leading, endPoint: .trailing)
                        .mask(Slider(value: $sliderValue, in: 1...7, step: 1))

                    Slider(value: $sliderValue, in: 1...7, step: 1)
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

                     Picker("Category", selection: $expenseItem.category) {
                        ForEach(0..<categories.all.count, id: \.self) { index in
                            Text(categories.all[index].name).tag(categories.all[index].name as String)
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

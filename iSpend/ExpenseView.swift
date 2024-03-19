import SwiftUI

struct ExpenseView: View {
    @ObservedObject var expenses: Expenses
    
    // Assuming Expenses is a class that contains an array of ExpenseItem
    // var items: [ExpenseItem] = []
    
    static var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM-dd"
        return formatter
    }()
    
    let deleteItems: (IndexSet) -> Void
    
    private var groupedExpenses: [ExpenseType: [ExpenseItem]] {
        Dictionary(grouping: expenses.allItems, by: { $0.type })
    }
    
    
    @State private var selectedExpenseItem: ExpenseItem?
    
    var body: some View {
        List {
            ForEach(ExpenseType.allCases, id: \.self) { expenseType in
                if let expenseItems = groupedExpenses[expenseType] {
                    Section(header: Text(expenseType.rawValue)) {
                        ForEach(expenseItems) { item in
                            ExpenseItemRow(item: item)
                                .onTapGesture {
                                    self.selectedExpenseItem = item // Set the selected item
                                }
                        }
                        .onDelete(perform: deleteItems)
                    }
                }
            }
        }.sheet(item: $selectedExpenseItem) { item in
            // Present the sheet for editing
            AddEditExpenseItemView(expenseItem: item)
        }
    }
}

struct ExpenseItemRow: View {
    var item: ExpenseItem
    
    var body: some View {
        HStack {
            Text(ExpenseView.dateFormatter.string(from: item.date))
            Text(item.name)
            Text(item.amount, format: .currency(code: Locale.current.currency?.identifier ?? "USD"))
        }
    }
}

    

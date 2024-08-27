import Foundation
import SwiftData
import SwiftUI

struct DataManagementView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.modelContext) private var modelContext

    var expenses: [ExpenseModel]

    @State private var isPresentingConfirm: Bool = false
    @State private var showAlert = false
    @State private var showErrorAlert = false
    @State private var errorMessage: String = ""

    private var exportButtonLabel: String {
        expenses.isEmpty ? "Export (No data to export)" : "Export"
    }

    var body: some View {
        NavigationView {
            List {
                resetButton(title: "Reset all expense data", modelTypes: [ExpenseModel.self], errorMessage: "Failed to clear all ExpenseModel data")
                
                resetButton(title: "Reset budget data", modelTypes: [BudgetModel.self], errorMessage: "Failed to clear all BudgetModel data.")
                
                resetButton(title: "Delete all data",
                            modelTypes: [CatergoriesModel.self],
                            errorMessage: "Failed to clear all data.")
                  
                Button(exportButtonLabel) {
                    let csvString = generateCSV(from: expenses)
                    UIPasteboard.general.string = csvString
                    print("CSV string copied to clipboard.")
                    showAlert = true
                }.alert(isPresented: $showAlert) {
                    Alert(
                        title: Text("\(expenses.count) exported"),
                        message: Text("Your data is now ready to paste into a file. Save the file with a .csv extension and view in your favorite spreadsheet program"),
                        dismissButton: .default(Text("OK"))
                    )
                }.disabled(expenses.isEmpty)
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }

    private func resetButton<T: PersistentModel>(title: String, modelTypes: [T.Type], errorMessage: String) -> some View {
        Button(title, role: .destructive) {
            isPresentingConfirm = true
        }
        .confirmationDialog("Are you sure?", isPresented: $isPresentingConfirm) {
            Button("Delete all data?", role: .destructive) {
                do {
                    for modelType in modelTypes {
                        try modelContext.delete(model: modelType)
                    }
                    dismiss()
                } catch {
                    self.errorMessage = errorMessage
                    showErrorAlert = true
                }
            }
        }
        .alert(isPresented: $showErrorAlert) {
            Alert(
                title: Text("Error"),
                message: Text(self.errorMessage),
                dismissButton: .default(Text("OK"))
            )
        }
    }

func generateCSV(from expenses: [ExpenseModel]) -> String {
    var csvString = "id,name,type,amount,note,date\n"

    let dateFormatter = DateFormatter()
    dateFormatter.dateStyle = .short
    dateFormatter.timeStyle = .none

    for expense in expenses {
        let dateString = dateFormatter.string(from: expense.date)
        let escapedNote = expense.note.replacingOccurrences(of: "\"", with: "\"\"") // Escape double quotes
        let csvRow = """
        "\(expense.id)",\(expense.name),\(expense.typeType),\(expense.amount),"\(escapedNote)",\(dateString)\n
        """
        csvString.append(contentsOf: csvRow)
    }

    return csvString
}

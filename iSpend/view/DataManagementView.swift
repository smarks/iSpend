import Foundation
import SwiftData
import SwiftUI

struct DataManagementView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.modelContext) private var modelContext

    var expenses: [ExpenseModel]

    @State private var showExportAlert = false
    @State private var showExpenseResetConfirm = false
    @State private var showBudgetResetConfirm = false
    @State private var showCategoryResetConfirm = false
    @State private var showErrorAlert = false
    @State private var errorMessage = ""

    var body: some View {
        NavigationStack {
            List {
                Button("Reset all expense data", role: .destructive) {
                    showExpenseResetConfirm = true
                }
                .confirmationDialog("Delete all expense data?", isPresented: $showExpenseResetConfirm, titleVisibility: .visible) {
                    Button("Delete", role: .destructive) {
                        deleteModel(ExpenseModel.self, errorMessage: "Failed to clear expense data")
                    }
                }

                Button("Reset budget data", role: .destructive) {
                    showBudgetResetConfirm = true
                }
                .confirmationDialog("Delete budget data?", isPresented: $showBudgetResetConfirm, titleVisibility: .visible) {
                    Button("Delete", role: .destructive) {
                        deleteModel(BudgetModel.self, errorMessage: "Failed to clear budget data")
                    }
                }

                Button("Reset categories and reflections", role: .destructive) {
                    showCategoryResetConfirm = true
                }
                .confirmationDialog("Delete all categories and reflections?", isPresented: $showCategoryResetConfirm, titleVisibility: .visible) {
                    Button("Delete", role: .destructive) {
                        deleteModel(EditableListItem.self, errorMessage: "Failed to delete categories and reflections")
                    }
                }

                Button(expenses.isEmpty ? "Export (no data)" : "Export") {
                    UIPasteboard.general.string = generateCSV(from: expenses)
                    showExportAlert = true
                }
                .disabled(expenses.isEmpty)
                .alert("\(expenses.count) records exported", isPresented: $showExportAlert) {
                    Button("OK", role: .cancel) {}
                } message: {
                    Text("Your data has been copied to the clipboard. Paste into a file with a .csv extension to open in a spreadsheet.")
                }
            }
            .alert("Error", isPresented: $showErrorAlert) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(errorMessage)
            }
            .navigationTitle("Data Management")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }

    private func deleteModel<T: PersistentModel>(_ type: T.Type, errorMessage: String) {
        do {
            try modelContext.delete(model: type)
            dismiss()
        } catch {
            self.errorMessage = errorMessage
            showErrorAlert = true
        }
    }

    // generateCSV is defined in Utils.swift as a free function.
}

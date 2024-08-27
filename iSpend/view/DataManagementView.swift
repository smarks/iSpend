//
//  DataManagementView.swift
//  iSpend
//
//  Created by Spencer Marks on 8/27/24.
//

import Foundation
import SwiftUI

struct DataManagementView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.modelContext) private var modelContext

    var expenses: [ExpenseModel]

    @State var isPresentingConfirm: Bool = false
    @State private var showAlert = false

    var exportButtonLabel: String {
        if expenses.isEmpty {
            "Export (No data to export)"
        } else {
            "Export"
        }
    }

    var body: some View {
        NavigationView {
            List {
                Button("Reset all expense data", role: .destructive) {
                    isPresentingConfirm = true
                    
                }.confirmationDialog("Are you sure?",
                                     isPresented: $isPresentingConfirm) {
                    Button("Delete all expenses?", role: .destructive) {
                        do {
                            try modelContext.delete(model: ExpenseModel.self)
                        } catch {
                            print("Failed to clear all ExpenseModel data.")
                        }
                    }
                }
                
                Button("Reset budget data", role: .destructive) {
                    isPresentingConfirm = true
                }.confirmationDialog("Are you sure?",
                                     isPresented: $isPresentingConfirm) {
                    Button("Delete all budget data restore defaults?", role: .destructive) {
                        do {
                            try modelContext.delete(model: BudgetModel.self)
                        } catch {
                            print("Failed to clear all BudgetModel data.")
                        }
                    }
                }
                
                Button("Delete all data", role: .destructive) {
                    isPresentingConfirm = true
                }.confirmationDialog("Are you sure?",
                                     isPresented: $isPresentingConfirm) {
                    Button("Delete all budget data restore defaults?", role: .destructive) {
                        do {
                            try modelContext.delete(model: BudgetModel.self)
                            try modelContext.delete(model: ExpenseModel.self)
                            try modelContext.delete(model: CatergoriesModel.self)
                            try modelContext.delete(model: MediationsModel.self)
                        } catch {
                            print("Failed to clear all  data.")
                        }
                    }
                }
                
                Button(exportButtonLabel) {
                    let csvString = generateCSV(from: expenses)
                    UIPasteboard.general.string = csvString
                    print("CSV string copied to clipboard.")
                    showAlert = true
                    
                }.alert(isPresented: $showAlert) {
                    Alert(
                        title: Text("\(expenses.count) exported "),
                        message: Text("Your data is now in  ready to paste into a file. Save the file with a .csv extension and view in your favorite spreadsheet program"),
                        dismissButton: .default(Text("OK"))
                    )
                }.disabled(expenses.isEmpty)
                
                
                
            }.toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
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

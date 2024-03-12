//
//  DataManagementView.swift
//  iSpend
//
//  Created by Spencer Marks on 3/5/24.
//

import Foundation
import SwiftUI

struct DataManagementView: View {
    @State var isPresentingConfirm: Bool = false
    @State private var showAlert = false

    var exportButtonLabel: String {
        if expenses.allItems.isEmpty {
            "Export (No data to export)"
        } else {
            "Export"
        }
    }

    @EnvironmentObject var expenses: Expenses
    var body: some View {
        List {
            Button("Reset", role: .destructive) {
                isPresentingConfirm = true

            }.confirmationDialog("Are you sure?",
                                 isPresented: $isPresentingConfirm) {
                Button("Delete all data and restore defaults?", role: .destructive) {
                    for key in Array(UserDefaults.standard.dictionaryRepresentation().keys) {
                        UserDefaults.standard.removeObject(forKey: key)
                    }
                    expenses.loadData()
                }
            }

            Button(exportButtonLabel) {
                let csvString = generateCSV(from: expenses.allItems)
                UIPasteboard.general.string = csvString
                print("CSV string copied to clipboard.")
                showAlert = true

            }.alert(isPresented: $showAlert) {
                Alert(
                    title: Text("\(expenses.allItems.count) exported "),
                    message: Text("Your data is now in  ready to paste into a file. Save the file with a .csv extension and view in your favorite spreadsheet program"),
                    dismissButton: .default(Text("OK"))
                )
            }.disabled(expenses.allItems.isEmpty)
        }
    }
}

func generateCSV(from expenses: [ExpenseItem]) -> String {
    var csvString = "id,name,type,amount,note,date\n"

    let dateFormatter = DateFormatter()
    dateFormatter.dateStyle = .short
    dateFormatter.timeStyle = .none

    for expense in expenses {
        let dateString = dateFormatter.string(from: expense.date)
        let escapedNote = expense.note.replacingOccurrences(of: "\"", with: "\"\"") // Escape double quotes
        let csvRow = """
        "\(expense.id.uuidString)",\(expense.name),\(expense.type.rawValue),\(expense.amount),"\(escapedNote)",\(dateString)\n
        """
        csvString.append(contentsOf: csvRow)
    }

    return csvString
}

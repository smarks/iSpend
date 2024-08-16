//
//  ExpenseModelView.swift
//  iSpend
//
//  Created by Spencer Marks on 8/15/24.
//

import Foundation
import SwiftUI

var dateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateFormat = "MM-dd"
    return formatter
}()
struct ExpenseModelView: View {
    @State var expenseModel: ExpenseModel
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Activity Details")) {
                    Text(expenseModel.name)
                    Text(dateFormatter.string(from: expenseModel.date))
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .lineLimit(1)
                    Text(expenseModel.amount, format: .localCurrency)
                        .frame(maxWidth: .infinity, alignment: .trailing)
                        .lineLimit(1)
                }
            }
            .navigationTitle("Activity Editor")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel", role: .cancel) {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveActivity()
                        dismiss()
                    }
                }
            }
        }
    }
    private func saveActivity() {
        print("Activity saved")
        modelContext.insert(expenseModel)
        print("Saving activity")
        print(expenseModel)
    }
}

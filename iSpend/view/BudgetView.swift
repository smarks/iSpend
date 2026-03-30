//
//  BudgetView.swift
//  iSpend
//
//  Created by Spencer Marks on 8/27/24.
//

import Foundation
import SwiftData
import SwiftUI

struct BudgetsView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.modelContext) private var modelContext

    @Bindable var necessaryBudget: BudgetModel
    @Bindable var discretionaryBudget: BudgetModel

    var body: some View {
        NavigationStack {
            Form {
                LabeledContent("Necessary Budget") {
                    TextField("Amount", value: $necessaryBudget.amount, format: .localCurrency)
                        .multilineTextAlignment(.trailing)
                        .keyboardType(.decimalPad)
                }
                LabeledContent("Discretionary Budget") {
                    TextField("Amount", value: $discretionaryBudget.amount, format: .localCurrency)
                        .multilineTextAlignment(.trailing)
                        .keyboardType(.decimalPad)
                }
            }
            .navigationTitle("Set Budgets")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        modelContext.rollback()
                        dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        do {
                            try modelContext.save()
                        } catch {
                            print("Failed to save budgets: \(error)")
                        }
                        dismiss()
                    }
                }
            }
        }
    }
}

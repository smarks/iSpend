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
                Section("Necessary Budget") {
                    LabeledContent("Amount") {
                        TextField("Amount", value: $necessaryBudget.amount, format: .localCurrency)
                            .multilineTextAlignment(.trailing)
                            .keyboardType(.decimalPad)
                    }
                    Picker("Period", selection: $necessaryBudget.periodMap) {
                        ForEach(BudgetPeriod.allCases, id: \.intValue) { period in
                            Text(period.rawValue).tag(period.intValue)
                        }
                    }
                    if necessaryBudget.budgetPeriod == .custom {
                        LabeledContent("Days in Period") {
                            TextField("Days", value: $necessaryBudget.customPeriodDays, format: .number)
                                .multilineTextAlignment(.trailing)
                                .keyboardType(.numberPad)
                        }
                    }
                }

                Section("Discretionary Budget") {
                    LabeledContent("Amount") {
                        TextField("Amount", value: $discretionaryBudget.amount, format: .localCurrency)
                            .multilineTextAlignment(.trailing)
                            .keyboardType(.decimalPad)
                    }
                    Picker("Period", selection: $discretionaryBudget.periodMap) {
                        ForEach(BudgetPeriod.allCases, id: \.intValue) { period in
                            Text(period.rawValue).tag(period.intValue)
                        }
                    }
                    if discretionaryBudget.budgetPeriod == .custom {
                        LabeledContent("Days in Period") {
                            TextField("Days", value: $discretionaryBudget.customPeriodDays, format: .number)
                                .multilineTextAlignment(.trailing)
                                .keyboardType(.numberPad)
                        }
                    }
                }
            }
            .navigationTitle("Set Budgets")
            .navigationBarTitleDisplayMode(.inline)
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

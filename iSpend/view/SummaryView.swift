//
//  SummaryView.swift
//  iSpend
//
//  Created by Spencer Marks on 8/24/24.
//

import Foundation
import SwiftUI

struct SummaryView: View {
    @Environment(\.modelContext) private var modelContext
    let expenses: [ExpenseModel]
    let label: String
    @Bindable var budget: BudgetModel
    @State private var isEditingBudget = false
    @State private var budgetAmountText = ""

    var totalExpenses: Double {
        expenses.reduce(0) { $0 + $1.amount }
    }

    var balance: Double {
        budget.amount - totalExpenses
    }

    var balanceColor: Color {
        balance < 0 ? .red : .green
    }

    private var progressBar: some View {
        let rawProgress = budget.amount > 0 ? totalExpenses / budget.amount : 0
        let clampedProgress = min(max(rawProgress, 0), 1.0)
        let barColor: Color = rawProgress < 0.6 ? .green : rawProgress < 0.9 ? .orange : .red
        return ProgressView(value: clampedProgress)
            .tint(barColor)
            .animation(.easeInOut(duration: 0.3), value: clampedProgress)
    }

    var body: some View {
        VStack(spacing: 6) {
            HStack {
                Text("Budget Period:")
                    .font(.subheadline)
                    .fontWeight(.medium)
                Picker("", selection: $budget.periodMap) {
                    ForEach(BudgetPeriod.allCases, id: \.intValue) { period in
                        Text(period.rawValue).tag(period.intValue)
                    }
                }
                .pickerStyle(.menu)
                .font(.subheadline)
                .labelsHidden()
                Spacer()
                Text(budget.periodLabel)
                    .font(.subheadline)
                    .fontWeight(.medium)
            }

            Divider()

            HStack {
                statColumn(label: "Spent", value: totalExpenses, color: balanceColor)
                Spacer()
                Button {
                    budgetAmountText = String(format: "%.2f", budget.amount)
                    isEditingBudget = true
                } label: {
                    statColumn(label: "Budget ✎", value: budget.amount, color: .blue)
                }
                .buttonStyle(.plain)
                Spacer()
                statColumn(label: "Remaining", value: balance, color: balanceColor)
            }

            progressBar
        }
        .alert("Edit Budget", isPresented: $isEditingBudget) {
            TextField("Amount", text: $budgetAmountText)
                .keyboardType(.decimalPad)
            Button("Save") {
                if let value = Double(budgetAmountText), value >= 0 {
                    budget.amount = value
                }
            }
            Button("Cancel", role: .cancel) { }
        }
    }

    private func statColumn(label: String, value: Double, color: Color) -> some View {
        VStack(alignment: .center, spacing: 2) {
            Text(value, format: .localCurrency)
                .font(.body)
                .fontWeight(.bold)
                .foregroundColor(color)
            Text(label)
                .font(.caption)
                .foregroundStyle(.primary)
        }
        .frame(maxWidth: .infinity)
    }
}

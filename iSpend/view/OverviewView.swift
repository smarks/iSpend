//
//  OverviewView.swift
//  iSpend
//

import SwiftUI

struct OverviewView: View {
    let necessaryExpenses: [ExpenseModel]
    let discretionaryExpenses: [ExpenseModel]
    let necessaryExpensesInPeriod: [ExpenseModel]
    let discretionaryExpensesInPeriod: [ExpenseModel]

    @State private var allTime = true

    private var activeNecessary: [ExpenseModel] {
        allTime ? necessaryExpenses : necessaryExpensesInPeriod
    }

    private var activeDiscretionary: [ExpenseModel] {
        allTime ? discretionaryExpenses : discretionaryExpensesInPeriod
    }

    private var necessaryTotal: Double {
        activeNecessary.reduce(0) { $0 + $1.amount }
    }

    private var discretionaryTotal: Double {
        activeDiscretionary.reduce(0) { $0 + $1.amount }
    }

    private var grandTotal: Double {
        necessaryTotal + discretionaryTotal
    }

    private var totalCount: Int {
        activeNecessary.count + activeDiscretionary.count
    }

    var body: some View {
        VStack(spacing: 8) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text(grandTotal, format: .localCurrency)
                        .font(.title2)
                        .fontWeight(.bold)
                        .contentTransition(.numericText())
                        .animation(.easeInOut(duration: 0.2), value: grandTotal)
                    Text("\(totalCount) expense\(totalCount == 1 ? "" : "s")")
                        .font(.caption)
                        .contentTransition(.numericText())
                        .animation(.easeInOut(duration: 0.2), value: totalCount)
                }
                Spacer()
                VStack(alignment: .trailing, spacing: 8) {
                    HStack(spacing: 4) {
                        Text("Necessary")
                            .font(.caption)
                        Text(necessaryTotal, format: .localCurrency)
                            .font(.caption)
                            .fontWeight(.medium)
                            .contentTransition(.numericText())
                            .animation(.easeInOut(duration: 0.2), value: necessaryTotal)
                    }
                    HStack(spacing: 4) {
                        Text("Discretionary")
                            .font(.caption)
                        Text(discretionaryTotal, format: .localCurrency)
                            .font(.caption)
                            .fontWeight(.medium)
                            .contentTransition(.numericText())
                            .animation(.easeInOut(duration: 0.2), value: discretionaryTotal)
                    }
                }
            }

            HStack {
                Button {
                    allTime.toggle()
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: allTime ? "checkmark.square.fill" : "square")
                            .foregroundStyle(allTime ? .blue : .secondary)
                        Text("All time")
                            .font(.caption)
                    }
                }
                .buttonStyle(.plain)
                Spacer()
            }
        }
    }
}

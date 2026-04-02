//
//  ReportsView.swift
//  iSpend
//

import Charts
import SwiftData
import SwiftUI

struct ReportsView: View {
    @Environment(\.dismiss) private var dismiss

    @Query private var allExpenses: [ExpenseModel]

    @State private var selectedType: Int = -1  // -1 = All, NECESSARY = 1, DISCRETIONARY = 2

    private let palette: [Color] = [
        .blue, .green, .orange, .red, .purple,
        .pink, .teal, .indigo, .yellow, .cyan
    ]

    private struct CategoryTotal: Identifiable {
        let id = UUID()
        let category: String
        let total: Double
        let color: Color
    }

    private var filteredExpenses: [ExpenseModel] {
        selectedType == -1 ? allExpenses : allExpenses.filter { $0.typeMap == selectedType }
    }

    private var categoryTotals: [CategoryTotal] {
        let sorted = Dictionary(grouping: filteredExpenses, by: \.category)
            .map { (category: $0.key, total: $0.value.reduce(0) { $0 + $1.amount }) }
            .filter { $0.total > 0 }
            .sorted { $0.total > $1.total }
        return sorted.enumerated().map { index, item in
            CategoryTotal(category: item.category, total: item.total, color: palette[index % palette.count])
        }
    }

    private var grandTotal: Double {
        categoryTotals.reduce(0) { $0 + $1.total }
    }

    var body: some View {
        NavigationStack {
            List {
                Section {
                    Picker("", selection: $selectedType) {
                        Text("All").tag(-1)
                        Text("Necessary").tag(NECESSARY)
                        Text("Discretionary").tag(DISCRETIONARY)
                    }
                    .pickerStyle(.segmented)
                }
                .listRowBackground(Color.clear)
                .listRowInsets(EdgeInsets())

                if categoryTotals.isEmpty {
                    Section {
                        Text("No expenses to report.")
                            .foregroundStyle(.secondary)
                            .frame(maxWidth: .infinity, alignment: .center)
                            .padding(.vertical, 24)
                    }
                } else {
                    Section {
                        Chart(categoryTotals) { item in
                            SectorMark(
                                angle: .value("Amount", item.total),
                                innerRadius: .ratio(0.5),
                                angularInset: 1.5
                            )
                            .foregroundStyle(item.color)
                            .cornerRadius(3)
                        }
                        .chartLegend(.hidden)
                        .frame(height: 260)
                        .padding(.vertical, 8)
                    }

                    Section("By Category") {
                        ForEach(categoryTotals) { item in
                            HStack(spacing: 10) {
                                Circle()
                                    .fill(item.color)
                                    .frame(width: 10, height: 10)
                                Text(item.category)
                                Spacer()
                                VStack(alignment: .trailing, spacing: 2) {
                                    Text(item.total, format: .localCurrency)
                                        .fontWeight(.medium)
                                    if grandTotal > 0 {
                                        Text("\(Int((item.total / grandTotal * 100).rounded()))%")
                                            .font(.caption)
                                            .foregroundStyle(.secondary)
                                    }
                                }
                            }
                        }
                        HStack {
                            Text("Total")
                                .fontWeight(.semibold)
                            Spacer()
                            Text(grandTotal, format: .localCurrency)
                                .fontWeight(.semibold)
                        }
                        .padding(.top, 2)
                    }
                }
            }
            .navigationTitle("Reports")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }
}

//
//  BudgetView.swift
//  iSpend
//
//  Created by Spencer Marks on 8/27/24.
//

import Foundation
import SwiftData
import SwiftUI

import Combine

struct BudgetsView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.modelContext) private var modelContext

    @State var discretionaryBudget: BudgetModel
    @State var necessaryBudget: BudgetModel
    @State var newDiscretionaryBudgetValue: String
    @State var newNecessaryBudgetValue: String
    @State var discretionaryBudgetChanged: Bool
    @State var necessaryBudgetChanged: Bool

    @FocusState private var isFocused: Bool

    private var disableSave: Bool {
        if necessaryBudgetChanged == true || discretionaryBudgetChanged == true {
            return true
        } else {
            return false
        }
    }

    init(necessaryBudget: BudgetModel, discretionaryBudget: BudgetModel) {
        self.newNecessaryBudgetValue = String(necessaryBudget.amount)
        self.newDiscretionaryBudgetValue = String(discretionaryBudget.amount)
        self.discretionaryBudget = discretionaryBudget
        self.necessaryBudget = necessaryBudget
        self.discretionaryBudgetChanged = false
        self.necessaryBudgetChanged = false
    }

    var body: some View {
        NavigationStack {
            Form {
                VStack {
                    BudgetEditorView(label: "Necessary Budget:", value: $newNecessaryBudgetValue).onChange(of: newNecessaryBudgetValue) { _, _ in
                        necessaryBudgetChanged = true
                        necessaryBudget.amount = Double(newNecessaryBudgetValue) ?? 0
                    }
                    BudgetEditorView(label: "Discretionary Budget:", value: $newDiscretionaryBudgetValue).onChange(of: newDiscretionaryBudgetValue) { _, _ in
                        discretionaryBudgetChanged = true
                        discretionaryBudget.amount = Double(newDiscretionaryBudgetValue) ?? 0
                    }
            }

            }.navigationTitle("Set Budgets")
                .toolbar {

                    ToolbarItem(placement: .navigationBarLeading) {
                        Button("Cancel") {
                            dismiss()
                        }
                    }
             
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Save") {
                            saveBudget()
                            dismiss()
                        }.disabled(!disableSave)
                    }
                }
        }
    }
    func saveBudget() {
        if necessaryBudgetChanged {
            modelContext.insert(necessaryBudget)
        }
        if discretionaryBudgetChanged {
            modelContext.insert(discretionaryBudget)
        }
    }
}

struct BudgetEditorView: View {
    @State var label: String
    @Binding var value: String

    var body: some View {
        Text(label).padding().bold()
        TextField(label, text: $value)
            .keyboardType(.numberPad)
            .onReceive(Just(value)) { newValue in
                let filtered = newValue.filter { "0123456789.".contains($0) }
                if filtered != newValue {
                    value = filtered
                }
            }
    }
}

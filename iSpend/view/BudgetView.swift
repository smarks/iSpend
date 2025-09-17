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
    @State var newDiscretionaryBudgetValue: Double
    @State var newNecessaryBudgetValue: Double
    @State var discretionaryBudgetChanged: Bool
    @State var necessaryBudgetChanged: Bool

    @FocusState private var isFocused: Bool
 
    
    private var disableSave: Bool {
        if necessaryBudgetChanged == true {
            return true
        }
        if discretionaryBudgetChanged == true {
            return true
        }
            return false
    }

    let formatter: NumberFormatter = {
           let formatter = NumberFormatter()
           formatter.numberStyle = .currency
           formatter.maximumFractionDigits = 2
           formatter.usesGroupingSeparator = true
           return formatter
       }()
    
    init(necessaryBudget: BudgetModel, discretionaryBudget: BudgetModel) {
        newNecessaryBudgetValue = necessaryBudget.amount
        newDiscretionaryBudgetValue = discretionaryBudget.amount
        self.discretionaryBudget = discretionaryBudget
        self.necessaryBudget = necessaryBudget
        discretionaryBudgetChanged = false
        necessaryBudgetChanged = false
    }
    
    let necessaryBudgetLabel:String = "Necessary Budget"
    let discretionaryBudgetLabel:String = "Discretionary Budget"
    var body: some View {
        NavigationStack {
            Form {
                VStack {
                    HStack {
                        Text(necessaryBudgetLabel).padding().bold()
                        TextField(necessaryBudgetLabel, value: $newNecessaryBudgetValue, formatter: formatter)
                            .onChange(of: newNecessaryBudgetValue) { _, _ in
                            necessaryBudgetChanged = true
                            necessaryBudget.amount = newNecessaryBudgetValue
                        }
                   }
                    HStack {
                        Text(discretionaryBudgetLabel).padding().bold()
                        TextField(discretionaryBudgetLabel, value: $newDiscretionaryBudgetValue, formatter: formatter)
                            .onChange(of: newDiscretionaryBudgetValue) { _, _ in
                            discretionaryBudgetChanged = true
                            discretionaryBudget.amount = newDiscretionaryBudgetValue
                        }
                            
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


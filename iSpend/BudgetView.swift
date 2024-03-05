//
//  BudgetView.swift
//  iSpend
//
//  Created by Spencer Marks on 3/5/24.
//

import Foundation
import SwiftUI
import Combine

struct BudgetsView: View {
     
    @EnvironmentObject var settings: Settings
    @ObservedObject var discretionaryBudget = DiscretionaryBudget()
    @ObservedObject var necessaryBudget = NecessaryBudget()
    var body: some View {
        NavigationView {
            VStack {
                List {
                    Text("Discretionary Budget:").padding().bold()
                    TextField("Discretionary Budget", text: $discretionaryBudget.amount)
                        .keyboardType(.numberPad)
                        .onReceive(Just(discretionaryBudget.amount)) { newValue in
                            let filtered = newValue.filter { "0123456789.".contains($0) }
                            if filtered != newValue {
                                discretionaryBudget.amount = filtered
                            }
                        }

                    Text("Necessary Budget:").padding().bold()
                    TextField("Necessary Budget", text: $necessaryBudget.amount)
                        .keyboardType(.numberPad)
                        .onReceive(Just(necessaryBudget.amount)) { newValue in
                            let filtered = newValue.filter { "0123456789.".contains($0) }
                            if filtered != newValue {
                                necessaryBudget.amount = filtered
                                
                            }
                        }
                }

            }.padding()

        }
        }
    }

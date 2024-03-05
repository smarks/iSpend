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

            Button("Export") {
                print("Export")
            }
        }
    }
}

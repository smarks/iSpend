//
//  SettingsView.swift
//  iSpend
//
//  Created by Spencer Marks on 1/24/24.
//

import Foundation
import SwiftUI

struct SettingView: View {
    @EnvironmentObject var settings: Settings
    @State private var stringNecessaryAmount = "0.0"
    @State private var stringDiscretionaryAmount = "0.0"
    @State var isPresentingConfirm: Bool = false
    @EnvironmentObject var expenses: Expenses
    var isDirty: Bool = false
    var disableSave: Bool {
        isDirty
    }

    var body: some View {
        NavigationView {
            Form {
                VStack {
                    Text("Discretionary Budget:")
                    NumericTextField(numericText: $stringDiscretionaryAmount, amountDouble: $settings.discretionaryBudget).border(Color.blue, width: 1)

                    Text("Necessary Budget:")
                    NumericTextField(numericText: $stringNecessaryAmount, amountDouble: $settings.necessaryBudget).border(Color.blue, width: 1)
               
                }.fixedSize()

                Spacer()
                HStack {
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

                .navigationTitle("Settings").bold()
                .toolbar {
                    Button("Cancel") {
                      
                    }

                    Button("Save") {
                         
                    } // .disabled(disableSave)
                } // toobar
            } // form
        } // nav
    } // view
} // struct

// new class Theme inherting from ObservableObject
final class Settings: ObservableObject {
    @Published var discretionaryBudget: Double {
        didSet { if let encoded = try? JSONEncoder().encode(discretionaryBudget) {
            UserDefaults.standard.set(encoded, forKey: "discretionaryBudget")

        } else {
            discretionaryBudget = 0.0
        }}
    }

    @Published var necessaryBudget: Double {
        didSet {
            if let encoded = try? JSONEncoder().encode(necessaryBudget) {
                UserDefaults.standard.set(encoded, forKey: "necessaryBudget")

            } else {
                necessaryBudget = 0.0
            }
        }
    }

    @Published var appVersion: String {
        didSet {
            appVersion = (Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String)!
        }
    }

    init() {
        necessaryBudget = 0.0
        discretionaryBudget = 0.0
        appVersion = (Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String)!
    }
}

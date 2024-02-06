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
    @Environment(\.dismiss) var dismiss

    var isDirty: Bool = false
    var disableSave: Bool {
        isDirty
    }
 
    var body: some View {
        NavigationStack {
            List() {
                NavigationLink(value: SettingsTypes.budgets) {
                    Text("Budgets")
                }
                NavigationLink(value: SettingsTypes.dataManagement) {
                    Text("Data Management")
                }
                NavigationLink(value: SettingsTypes.about) {
                    Text("About")
                }
                .navigationDestination(for: SettingsTypes.self) { type in
                    switch type {
                    case .budgets:
                        let budgets:Budgets = Budgets( name: "Budgets",discretionaryBudget: settings.discretionaryBudget, necessaryBudget: settings.necessaryBudget)
                        BudgetsView(budgets: budgets)
                    case .dataManagement:
                        DataManagementView()
                    case .about:
                        AboutView(version: settings.appVersion)
                    }
                }.navigationBarTitleDisplayMode(.large)
            }
        }
    }
}

struct BudgetsView: View {
    @State private var stringNecessaryAmount = "0.0"
    @State private var stringDiscretionaryAmount = "0.0"
    @State var budgets: Budgets

    var body: some View {
        VStack {
            Text("Discretionary Budget:")
            NumericTextField(numericText: $stringDiscretionaryAmount, amountDouble: $budgets.discretionaryBudget).border(Color.blue, width: 1)

            Text("Necessary Budget:")
            NumericTextField(numericText: $stringNecessaryAmount, amountDouble: $budgets.necessaryBudget).border(Color.blue, width: 1)
        }
    }
}

 struct DataManagementView: View {
    @State var isPresentingConfirm: Bool = false
    @EnvironmentObject var expenses: Expenses
     var body: some View {
         List() {
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

struct AboutView: View {
    let version: String
    var body: some View {
        Text("iSpend \(version)")
        Text("by Spencer Marks   Origami Software")
        Spacer()
        Text("Thanks Paul")
    }
}

enum SettingsTypes: String, CaseIterable, Hashable {
    case budgets = "Budgets"
    case dataManagement = "Data Management"
    case about
}
struct Budgets: Identifiable, Hashable {
    static var idGenerator = 0 // Static property to keep track of the last ID assigned
    
    let id: Int
    let name: String
    var discretionaryBudget: Double
    var necessaryBudget: Double
    
    // Custom initializer
    init(name: String, discretionaryBudget: Double, necessaryBudget: Double) {
        self.id = Budgets.generateNextId()
        self.name = name
        self.discretionaryBudget = discretionaryBudget
        self.necessaryBudget = necessaryBudget
    }
    
    // Static method to increment and return the next ID
    private static func generateNextId() -> Int {
        idGenerator += 1
        return idGenerator
    }
}

 
 

struct About: Identifiable, Hashable {
    let name: String
    let id: Int
}

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

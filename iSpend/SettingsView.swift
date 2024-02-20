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
       
            NavigationStack{
                List {
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
                            let budgets: Budgets = Budgets(name: "Budgets", discretionaryBudget: settings.discretionaryBudget, necessaryBudget: settings.necessaryBudget)
                            BudgetsView(budgets: budgets)
                        case .dataManagement:
                            DataManagementView()
                        case .about:
                            AboutView(version: settings.appVersion, buildNumber: Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as! String, appIcon: AppIconProvider.appIcon())
                        }
                    }.navigationBarTitleDisplayMode(.large).toolbar {
                        Button("Done") {
                            dismiss()
                        }
                    }
                }
            }
         
    }
}

struct BudgetsView: View {
    @State private var stringNecessaryAmount = "0.0"
    @State private var stringDiscretionaryAmount = "0.0"
    @State var budgets: Budgets
    @EnvironmentObject var settings: Settings
    var disableSave: Bool {
        return settings.discretionaryBudget == budgets.discretionaryBudget &&
        settings.necessaryBudget == budgets.necessaryBudget
    }
    var body: some View {
        NavigationView {
            VStack {
                List{
                    Text("Discretionary Budget:").padding().bold()
                    NumericTextField(numericText: $stringDiscretionaryAmount, amountDouble: $budgets.discretionaryBudget).fixedSize()
                    
                    Text("Necessary Budget:").padding().bold()
                    NumericTextField(numericText: $stringNecessaryAmount, amountDouble: $budgets.necessaryBudget).fixedSize()
                }.padding()
            }
           
        }.navigationBarTitleDisplayMode(.large).toolbar {
            Button("Save") {
                settings.necessaryBudget = budgets.necessaryBudget
                settings.discretionaryBudget  = budgets.discretionaryBudget
            }.disabled(disableSave)
            
        }
    }
}

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

enum AppIconProvider {
    static func appIcon(in bundle: Bundle = .main) -> String {
        guard let icons = bundle.object(forInfoDictionaryKey: "CFBundleIcons") as? [String: Any],

              let primaryIcon = icons["CFBundlePrimaryIcon"] as? [String: Any],

              let iconFiles = primaryIcon["CFBundleIconFiles"] as? [String],

              let iconFileName = iconFiles.last else {
            fatalError("Could not find icons in bundle")
        }

        return iconFileName
    }
}

struct AboutView: View {
    let version: String
    let buildNumber: String
    let appIcon: String

    var body: some View {
        Text("iSpend").bold().font(.system(size: 18))
        if let image = UIImage(named: appIcon) {
            Image(uiImage: image)
        }  
        Text("Thoughtful spending made easier").italic().font(.system(size: 12))
        Spacer()
        Text("Version \(version) ").font(.system(size: 14))
        Text("(build \(buildNumber))").font(.system(size: 12))     
        Spacer()
        Text("Designed &  Programmed by:").font(.system(size: 12))
        Text("Spencer Marks ⌭ Origami Software").font(.system(size: 12))
        Spacer()
        let link = "[Origami Software](https://origamisoftware.com)"
        Text(.init(link))
        Spacer()
        let sourceCode = "[M.I.T. licensed Source Code](https://github.com/smarks/iSpend)"
        Text(.init(sourceCode)).font(.system(size: 12))
        Spacer()
        let privacyPolicyLink = "[Privacy Policy](https://origamisoftware.com/about/ispend-privacy)"
        Text(.init(privacyPolicyLink)).font(.system(size: 12))
        Spacer()
        let hackWithSwiftURL = "[Thanks Paul](https://www.hackingwithswift.com)"
        Text(.init(hackWithSwiftURL))
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
        id = Budgets.generateNextId()
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
        }  }
    }

    @Published var necessaryBudget: Double {
        didSet {
            if let encoded = try? JSONEncoder().encode(necessaryBudget) {
                UserDefaults.standard.set(encoded, forKey: "necessaryBudget")
            }
        }
    }

    @Published var appVersion: String {
        didSet {
            appVersion = (Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String)!
        }
    }

    init() {
        necessaryBudget = UserDefaults.standard.double(forKey: "necessaryBudget")
        discretionaryBudget = UserDefaults.standard.double(forKey: "discretionaryBudget")
        appVersion = (Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String)!
    }
}

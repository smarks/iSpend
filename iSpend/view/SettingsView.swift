//
//  SettingsView.swift
//  iSpend
//
//  Created by Spencer Marks on 8/27/24.
//

import Foundation
import SwiftData
import SwiftUI

class AppVersion: ObservableObject {
    @Published var version: String {
        didSet {
            version = (Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String)!
        }
    }

    init() {
        version = (Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String)!
    }
}


struct SettingsView: View {
    enum SettingsTypes: String, CaseIterable, Hashable {
        case budgets = "Budgets"
        case dataManagement = "Data Management"
        case categories = "Categories"
        case mediations = "Mdiations"
        case about = "About"
    }

    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) var dismiss

    @Query
    private var expenses: [ExpenseModel]
    
    private var data:Data = Data()
    
    @State var showBudgetView: Bool = false
    @State var showDataManagementView: Bool = false
    @State var showCategoriestView: Bool = false
    @State var showMediationsView: Bool = false
    @State var showAboutView: Bool = false

    var appVersion:AppVersion = AppVersion()

    var isDirty: Bool = false
    var disableSave: Bool {
        isDirty
    }

    @Query(filter: #Predicate<ExpenseModel> { expense in expense.type == NECESSARY }, sort: [SortDescriptor(\ExpenseModel.date)])
    var necessaryExpenses: [ExpenseModel]

    @Query(filter: #Predicate<ExpenseModel> { expense in expense.type == DISCRETIONARY }, sort: [SortDescriptor(\ExpenseModel.date)])
    var discretionaryExpenses: [ExpenseModel]

    @Query(filter: #Predicate<BudgetModel> { budget in budget.type == NECESSARY })
    var necessaryBudgets: [BudgetModel]

    var necessaryBudget: BudgetModel {
        if necessaryBudgets.isEmpty {
            let budgetModel: BudgetModel = BudgetModel(type: NECESSARY, amount: 0)
            modelContext.insert(budgetModel)
            return budgetModel
        } else {
            return necessaryBudgets[0]
        }
    }

    @Query(filter: #Predicate<BudgetModel> { budget in budget.type == DISCRETIONARY })
    var discretionaryBudgets: [BudgetModel]

    var discretionaryBudget: BudgetModel {
        if discretionaryBudgets.isEmpty {
            let budgetModel: BudgetModel = BudgetModel(type: DISCRETIONARY, amount: 0)
            modelContext.insert(BudgetModel(type: DISCRETIONARY, amount: 0))
            return budgetModel
        } else {
            return discretionaryBudgets[0]
        }
    }
    
    
    var body: some View {
        NavigationView {
            VStack {
                List {
                    Button {
                        showBudgetView = true
                    } label: {
                        Text("Budgets")
                    }.frame(alignment: .leading)
                    Button {
                        showDataManagementView = true
                    } label: {
                        Text("Datat Management")
                    }.frame(alignment: .leading)
                    Button {
                        showCategoriestView = true
                    } label: {
                        Text("Categories")
                    }
                    Button {
                        showMediationsView = true
                    } label: {
                        Text("Mediations")
                    }
                    Button {
                        showAboutView = true
                    } label: {
                        Text("About")
                    }
                }
            }
            .navigationTitle("Preferences and Settings").navigationBarTitleDisplayMode(.inline).navigationBarBackButtonHidden(false)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }

        }.sheet(isPresented: $showBudgetView) {
            BudgetsView(necessaryBudget:necessaryBudget, discretionaryBudget: discretionaryBudget)
        }.sheet(isPresented: $showDataManagementView) {
            DataManagementView(expenses:expenses)
        }.sheet(isPresented: $showCategoriestView) {
            ConfigurationView()
        }.sheet(isPresented: $showMediationsView) {
            ConfigurationView()
        }.sheet(isPresented: $showAboutView) {
            AboutView(version: appVersion.version, buildNumber: Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as! String, appIcon: AppIconProvider.appIcon())
        }
    }
}

enum AppIconProvider {
    static func appIcon(in bundle: Bundle = .main) -> String {
        // Attempt to retrieve the macOS app icon name
        if let iconFileName = bundle.object(forInfoDictionaryKey: "CFBundleIconFile") as? String {
            return iconFileName
        }

        // Attempt to retrieve the iOS app icon name
        guard let icons = bundle.object(forInfoDictionaryKey: "CFBundleIcons") as? [String: Any],
              let primaryIcon = icons["CFBundlePrimaryIcon"] as? [String: Any],
              let iconFiles = primaryIcon["CFBundleIconFiles"] as? [String],
              let iconFileName = iconFiles.last else {
            fatalError("Could not find icons in bundle")
        }

        return iconFileName
    }
}





struct ConfigurationView: View {
    var body: some View {
        /*@START_MENU_TOKEN@*//*@PLACEHOLDER=Hello, world!@*/Text("Hello, world!")/*@END_MENU_TOKEN@*/
    }
}


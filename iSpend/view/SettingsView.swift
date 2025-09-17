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
        case mediations = "Mediations"
        case about = "About"
    }

    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) var dismiss

    @Query
    private var expenses: [ExpenseModel]

    private var data: Data = Data()

    @State var showBudgetView: Bool = false
    @State var showDataManagementView: Bool = false
    @State var showCategoriesView: Bool = false
    @State var showMediationsView: Bool = false
    @State var showAboutView: Bool = false

    var appVersion: AppVersion = AppVersion()

    var isDirty: Bool = false
    var disableSave: Bool {
        isDirty
    }

    @Query(filter: #Predicate<ExpenseModel> { expense in expense.typeMap == NECESSARY }, sort: [SortDescriptor(\ExpenseModel.date)])
    var necessaryExpenses: [ExpenseModel]

    @Query(filter: #Predicate<ExpenseModel> { expense in expense.typeMap == DISCRETIONARY }, sort: [SortDescriptor(\ExpenseModel.date)])
    var discretionaryExpenses: [ExpenseModel]

    @Query(filter: #Predicate<BudgetModel> { budget in budget.type == NECESSARY })
    var necessaryBudgets: [BudgetModel]

    // Categories and mediations are now handled within EditableListManager

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
            modelContext.insert(budgetModel)
            return budgetModel
        } else {
            return discretionaryBudgets[0]
        }
    }

    var body: some View {
        NavigationStack {
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
                        Text("Data Management")
                    }.frame(alignment: .leading)
                    Button {
                        showCategoriesView = true
                    } label: {
                        HStack {
                            Text("Categories")
                            Spacer()
                            Image(systemName: "chevron.right")
                                .foregroundColor(.secondary)
                        }
                    }
                    Button {
                        showMediationsView = true
                    } label: {
                        HStack {
                            Text("Reflections")
                            Spacer()
                            Image(systemName: "chevron.right")
                                .foregroundColor(.secondary)
                        }
                    }
                    Button {
                        showAboutView = true
                    } label: {
                        Text("About")
                    }
                }
            }
            .navigationTitle("Preferences and Settings")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(false)
            .toolbar {
                ToolbarItemGroup(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
        .sheet(isPresented: $showBudgetView) {
            BudgetsView(necessaryBudget: necessaryBudget, discretionaryBudget: discretionaryBudget)
                .environment(\EnvironmentValues.modelContext, modelContext)
        }
        .sheet(isPresented: $showDataManagementView) {
            DataManagementView(expenses: expenses)
                .environment(\EnvironmentValues.modelContext, modelContext)
        }
        .sheet(isPresented: $showCategoriesView) {
            EditableListManager(title: "Categories", itemType: CATEGORY, placeholder: "Add Category")
                .environment(\EnvironmentValues.modelContext, modelContext)
        }
        .sheet(isPresented: $showMediationsView) {
            EditableListManager(title: "Mediations", itemType: MEDIATION, placeholder: "Add Mediation")
                .environment(\EnvironmentValues.modelContext, modelContext)
        }
        .sheet(isPresented: $showAboutView) {
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

// ConfigurationView and EditListItemView have been replaced with EditableListManager

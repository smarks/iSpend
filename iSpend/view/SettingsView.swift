//
//  SettingsView.swift
//  iSpend
//
//  Created by Spencer Marks on 8/27/24.
//

import Foundation
import SwiftData
import SwiftUI

struct SettingsView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) var dismiss

    @Query
    private var expenses: [ExpenseModel]

    @Query(filter: #Predicate<BudgetModel> { budget in budget.type == NECESSARY })
    private var necessaryBudgets: [BudgetModel]

    @Query(filter: #Predicate<BudgetModel> { budget in budget.type == DISCRETIONARY })
    private var discretionaryBudgets: [BudgetModel]

    // Budget creation is handled by iSpendApp on first launch; these just read.
    private var necessaryBudget: BudgetModel {
        necessaryBudgets.first ?? BudgetModel(type: NECESSARY, amount: 0)
    }

    private var discretionaryBudget: BudgetModel {
        discretionaryBudgets.first ?? BudgetModel(type: DISCRETIONARY, amount: 0)
    }

    @State private var showBudgetView: Bool = false
    @State private var showDataManagementView: Bool = false
    @State private var showCategoriesView: Bool = false
    @State private var showMediationsView: Bool = false
    @State private var showAboutView: Bool = false

    private var appVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "?"
    }

    private var buildNumber: String {
        Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String ?? "?"
    }

    var body: some View {
        NavigationStack {
            VStack {
                List {
                    Section {
                        CloudSyncStatusView()
                    } header: {
                        Text("Data Sync")
                    }
                    .listRowBackground(Color.clear)
                    .listRowInsets(EdgeInsets())

                    Section("Settings") {
                        Button {
                            showBudgetView = true
                        } label: {
                            Text("Budgets")
                        }
                        Button {
                            showDataManagementView = true
                        } label: {
                            Text("Data Management")
                        }
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
            }
            .navigationTitle("Preferences and Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItemGroup(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .buttonStyle(.borderless)
                }
            }
        }
        .sheet(isPresented: $showBudgetView) {
            BudgetsView(necessaryBudget: necessaryBudget, discretionaryBudget: discretionaryBudget)
                .environment(\.modelContext, modelContext)
        }
        .sheet(isPresented: $showDataManagementView) {
            DataManagementView(expenses: expenses)
                .environment(\.modelContext, modelContext)
        }
        .sheet(isPresented: $showCategoriesView) {
            EditableListManager(title: "Categories", itemType: CATEGORY, placeholder: "Add Category")
                .environment(\.modelContext, modelContext)
        }
        .sheet(isPresented: $showMediationsView) {
            EditableListManager(title: "Reflections", itemType: MEDIATION, placeholder: "Add Reflection")
                .environment(\.modelContext, modelContext)
        }
        .sheet(isPresented: $showAboutView) {
            AboutView(version: appVersion, buildNumber: buildNumber, appIcon: AppIconProvider.appIcon())
        }
    }
}

enum AppIconProvider {
    static func appIcon(in bundle: Bundle = .main) -> String {
        if let iconFileName = bundle.object(forInfoDictionaryKey: "CFBundleIconFile") as? String,
           !iconFileName.isEmpty {
            return iconFileName
        }

        if let icons = bundle.object(forInfoDictionaryKey: "CFBundleIcons") as? [String: Any],
           let primaryIcon = icons["CFBundlePrimaryIcon"] as? [String: Any],
           let iconFiles = primaryIcon["CFBundleIconFiles"] as? [String],
           let iconFileName = iconFiles.last {
            return iconFileName
        }

        return "" // Fallback: AboutView should handle an empty string gracefully
    }
}

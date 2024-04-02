//
//  SettingsView.swift
//  iSpend
//
//  Created by Spencer Marks on 1/24/24.
//

import Combine
import Foundation
import SwiftUI

enum SettingsTypes: String, CaseIterable, Hashable {
    case budgets = "Budgets"
    case dataManagement = "Data Management"
    case configuration = "Configuration"
    case about = "About"
}

struct SettingView: View {
    @EnvironmentObject var settings: Settings
    @Environment(\.dismiss) var dismiss
    @ObservedObject var discretionaryBudget = DiscretionaryBudget()
    @ObservedObject var necessaryBudget = NecessaryBudget()
   
    var isDirty: Bool = false
    var disableSave: Bool {
        isDirty
    }

    var body: some View {
        NavigationStack {
            List {
                NavigationLink(value: SettingsTypes.budgets) {
                    Text("Budgets")
                }
                NavigationLink(value: SettingsTypes.dataManagement) {
                    Text("Data Management")
                }
                NavigationLink(value: SettingsTypes.configuration) {
                    Text("Configuration")
                }
                NavigationLink(value: SettingsTypes.about) {
                    Text("About")
                }
                .navigationDestination(for: SettingsTypes.self) { type in
                    switch type {
                    case .budgets:
                        BudgetsView()
                    case .dataManagement:
                        DataManagementView()
                    case .configuration:
                        ConfigurationView()

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

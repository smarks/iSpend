//  SettingsView.swift
//  iSpend
//
//  Created by Spencer Marks on 1/24/24.

import Combine
import Foundation
import SwiftUI

enum SettingsTypes: String, CaseIterable, Hashable {
    case budgets = "Budgets"
    case dataManagement = "Data Management"
    case categories = "Categories"
    case mediations = "Mdiations"
    case about = "About"
}

struct SettingView: View {
    @EnvironmentObject var settings: Settings
    @Environment(\.dismiss) var dismiss
    @ObservedObject var discretionaryBudget = DiscretionaryBudget()
    @ObservedObject var necessaryBudget = NecessaryBudget()
    @ObservedObject var categories: Categories = Categories()
    @ObservedObject var mediations: Mediations = Mediations()

    var isDirty: Bool = false
    var disableSave: Bool {
        isDirty
    }

    var body: some View {
        NavigationStack {
            List(SettingsTypes.allCases, id: \.self) { settingType in
                NavigationLink(settingType.rawValue, value: settingType)
            }
            .navigationDestination(for: SettingsTypes.self) { type in
                switch type {
                case .budgets:
                    BudgetsView()
                case .dataManagement:
                    DataManagementView()
                case .categories:
                    ConfigurationView(items: $categories.list, title: "Categories" )
                case .mediations:
                    ConfigurationView(items: $mediations.list, title: "Mediations" )
                case .about:
                    AboutView(version: settings.appVersion, buildNumber: Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as! String, appIcon: AppIconProvider.appIcon())
                    //swiftlint:disable:previous force_cast
                }
            }
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                Button("Done") {
                    dismiss()
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


//
//  SettingsView.swift
//  iSpend
//
//  Created by Spencer Marks on 1/24/24.
//

import Combine
import Foundation
import SwiftUI

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
                NavigationLink(value: SettingsTypes.about) {
                    Text("About")
                }
                .navigationDestination(for: SettingsTypes.self) { type in
                    switch type {
                    case .budgets:

                        BudgetsView( )
                         
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

struct About: Identifiable, Hashable {
    let name: String
    let id: Int
}

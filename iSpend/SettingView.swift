//
//  SettingView.swift
//  Revisit
//
//  Created by Spencer Marks on 5/16/24.
//

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

class Settings: ObservableObject {
    @Published var appVersion: String {
        didSet {
            appVersion = (Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String)!
        }
    }
    
    init() {
        appVersion = (Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String)!
    }
}

struct SettingView: View {
    
    @State var settings: Settings
    @Environment(\.dismiss) var dismiss
    @ObservedObject var discretionaryBudget = DiscretionaryBudget()
    @ObservedObject var necessaryBudget = NecessaryBudget()
    @ObservedObject var categories: Categories = Categories()
    @ObservedObject var mediations: Mediations = Mediations()

    @State var expenses:Expenses
    
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
                    DataManagementView(expenses: expenses)
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

struct BudgetsView: View {
    @EnvironmentObject var settings: Settings
    @ObservedObject var discretionaryBudget = DiscretionaryBudget()
    @ObservedObject var necessaryBudget = NecessaryBudget()
    var body: some View {
        NavigationView {
            VStack {
                List {
                    Text("Discretionary Budget:").padding().bold()
                    TextField("Discretionary Budget", text: $discretionaryBudget.amount)
                        .keyboardType(.numberPad)
                        .onReceive(Just(discretionaryBudget.amount)) { newValue in
                            let filtered = newValue.filter { "0123456789.".contains($0) }
                            if filtered != newValue {
                                discretionaryBudget.amount = filtered
                            }
                        }

                    Text("Necessary Budget:").padding().bold()
                    TextField("Necessary Budget", text: $necessaryBudget.amount)
                        .keyboardType(.numberPad)
                        .onReceive(Just(necessaryBudget.amount)) { newValue in
                            let filtered = newValue.filter { "0123456789.".contains($0) }
                            if filtered != newValue {
                                necessaryBudget.amount = filtered
                            }
                        }
                }

            }.padding()
        }
    }
}

struct DataManagementView: View {
    @State var expenses: Expenses

    @State var isPresentingConfirm: Bool = false
    @State private var showAlert = false

    var exportButtonLabel: String {
        if expenses.allItems.isEmpty {
            "Export (No data to export)"
        } else {
            "Export"
        }
    }


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

            Button(exportButtonLabel) {
                let csvString = generateCSV(from: expenses.allItems)
                UIPasteboard.general.string = csvString
                print("CSV string copied to clipboard.")
                showAlert = true

            }.alert(isPresented: $showAlert) {
                Alert(
                    title: Text("\(expenses.allItems.count) exported "),
                    message: Text("Your data is now in  ready to paste into a file. Save the file with a .csv extension and view in your favorite spreadsheet program"),
                    dismissButton: .default(Text("OK"))
                )
            }.disabled(expenses.allItems.isEmpty)
        }
    }
}

func generateCSV(from expenses: [ExpenseItem]) -> String {
    var csvString = "id,name,type,amount,note,date\n"

    let dateFormatter = DateFormatter()
    dateFormatter.dateStyle = .short
    dateFormatter.timeStyle = .none

    for expense in expenses {
        let dateString = dateFormatter.string(from: expense.date)
        let escapedNote = expense.note.replacingOccurrences(of: "\"", with: "\"\"") // Escape double quotes
        let csvRow = """
        "\(expense.id.uuidString)",\(expense.name),\(expense.type.rawValue),\(expense.amount),"\(escapedNote)",\(dateString)\n
        """
        csvString.append(contentsOf: csvRow)
    }

    return csvString
}

struct ConfigurationView: View {
    @Environment(\.dismiss) var dismiss

    @State private var showingSheet = false
    @State private var editingText: String = ""
    @Binding var items: [String] // Use a binding to allow the view to modify the array
    var title: String

    var body: some View {
        NavigationView {
            List {
                ForEach(items, id: \.self) { stringToShow in
                    Text(stringToShow)
                }
                .onDelete(perform: remove) // Use onDelete here
            }
            .navigationTitle(title)
            .toolbar {
                Button {
                    editingText = ""
                    showingSheet = true
                } label: {
                    Image(systemName: "plus")
                }
            }
        }
        .sheet(isPresented: $showingSheet) {
            EditLabelView(itemText: editingText, editTitle: title) { newText in
                if !newText.isEmpty {
                    items.append(newText)
                    showingSheet = false
                }
            }
        }
    }

    func remove(at offsets: IndexSet) {
        items.remove(atOffsets: offsets)
    }
}
struct EditLabelView: View {
    @Environment(\.dismiss) var dismiss
    var onSave: (String) -> Void
    @State private var itemText: String
    var editTitle: String

    init(itemText: String = "", editTitle: String = "Add", onSave: @escaping (String) -> Void) {
        _itemText = State(initialValue: itemText)
        self.editTitle = editTitle
        self.onSave = onSave
    }

    var body: some View {
        NavigationView {
            VStack {
                TextField("Enter item", text: $itemText)
                    .padding(.horizontal)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
            }
            .padding()
            .navigationTitle(editTitle)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        onSave(itemText)
                        dismiss()
                    }
                }
            }
        }
    }
}

 
 


struct AboutView: View {
    let version: String
    let buildNumber: String
    let appIcon: String

    var body: some View {
        VStack(spacing: 10) {
            appTitle
            appIconImage
            appDescription
            versionInformation
            developerInformation
            linksSection
        }
        .padding()
    }

    private var appTitle: some View {
        Text("iSpend")
            .bold()
            .font(.system(size: 18))
    }

    private var appIconImage: some View {
        // Correctly handle the optional UIImage and ensure a view is always returned
        Group {
            if let image = UIImage(named: appIcon) {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 100, height: 100)
            } else {
                // Provide a fallback view in case the image is not found
                Image(systemName: "app.fill")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 100, height: 100)
            }
        }
    }

    private var appDescription: some View {
        Text("Thoughtful spending made easier")
            .italic()
            .font(.system(size: 12))
    }

    private var versionInformation: some View {
        VStack {
            Text("Version \(version)")
                .font(.system(size: 14))
            Text("(build \(buildNumber))")
                .font(.system(size: 12))
        }
    }

    private var developerInformation: some View {
        VStack {
            Text("Designed & Programmed by:")
                .font(.system(size: 12))
            Text("Spencer Marks ⌭ Origami Software")
                .font(.system(size: 12))
        }
    }

    private var linksSection: some View {
        VStack {
            Link("Origami Software", destination: URL(string: "https://origamisoftware.com")!)
            Link("M.I.T. licensed Source Code", destination: URL(string: "https://github.com/smarks/iSpend")!)
            Link("Privacy Policy", destination: URL(string: "https://origamisoftware.com/about/ispend-privacy")!)
            Link("Thanks Paul", destination: URL(string: "https://www.hackingwithswift.com")!)
        }
        .font(.system(size: 12))
    }
}

struct About: Identifiable, Hashable {
    let name: String
    let id: Int
}

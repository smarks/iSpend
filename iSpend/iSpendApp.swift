//
//  iExpenseApp.swift
//  iSpend
//
//  Original code created by Paul Hudson on 01/11/2021.
//  Extended by Spencer Marks starting on 07/25/2023
//

import SwiftData
import SwiftUI

@main
struct iSpendApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([ExpenseModel.self, BudgetModel.self, CatergoriesModel.self, MediationsModel.self])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(sharedModelContainer)
    }
}

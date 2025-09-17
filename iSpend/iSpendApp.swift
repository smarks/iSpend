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
        let schema = Schema([ExpenseModel.self, BudgetModel.self, EditableListItem.self])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            let container = try ModelContainer(for: schema, configurations: [modelConfiguration])
            return container
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .onAppear {
                    initializeDefaultDataIfNeeded()
                }
        }
        .modelContainer(sharedModelContainer)
    }

    func initializeDefaultDataIfNeeded() {
        let context = sharedModelContainer.mainContext

        // Check if categories exist
        let categoryDescriptor = FetchDescriptor<EditableListItem>(
            predicate: #Predicate { $0.type == CATEGORY }
        )

        do {
            let existingCategories = try context.fetch(categoryDescriptor)
            if existingCategories.isEmpty {
                // Add some default categories
                let defaultCategories = ["Food", "Transport", "Shopping", "Entertainment", "Bills", "Other"]
                for categoryName in defaultCategories {
                    let category = EditableListItem(text: categoryName, type: CATEGORY)
                    context.insert(category)
                }
            }

            // Check if mediations exist
            let mediationDescriptor = FetchDescriptor<EditableListItem>(
                predicate: #Predicate { $0.type == MEDIATION }
            )

            let existingMediations = try context.fetch(mediationDescriptor)
            if existingMediations.isEmpty {
                // Add some default mediations
                let defaultMediations = [
                    "Take a moment to reflect on this purchase.",
                    "Will this bring lasting value?",
                    "Is this aligned with your goals?"
                ]
                for mediationText in defaultMediations {
                    let mediation = EditableListItem(text: mediationText, type: MEDIATION)
                    context.insert(mediation)
                }
            }
        } catch {
            print("Error initializing default data: \(error)")
        }
    }
}

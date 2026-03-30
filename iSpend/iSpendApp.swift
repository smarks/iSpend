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
        let schema = Schema([
            ExpenseModel.self,
            BudgetModel.self,
            EditableListItem.self
        ])

        func makeContainer(configuration: ModelConfiguration, label: String) throws -> ModelContainer {
            do {
                let container = try ModelContainer(for: schema, configurations: [configuration])
                print("SwiftData: Loaded ModelContainer using \(label) configuration")
                return container
            } catch {
                print("SwiftData: Failed to load ModelContainer using \(label) configuration: \(error)")
                throw error
            }
        }

        // 1) Try CloudKit-backed store
        do {
            let cloudKitConfig = ModelConfiguration(
                schema: schema,
                isStoredInMemoryOnly: false,
                cloudKitDatabase: .automatic
            )
            return try makeContainer(configuration: cloudKitConfig, label: "CloudKit")
        } catch {
            // Fall through to local persistent store
        }

        // 2) Try local on-disk store (no CloudKit)
        do {
            let localConfig = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
            return try makeContainer(configuration: localConfig, label: "Local Persistent Store")
        } catch {
            // Fall through to in-memory store
        }

        // 3) Final fallback: in-memory store to keep the app running
        do {
            let memoryConfig = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
            return try makeContainer(configuration: memoryConfig, label: "In-Memory Store (Fallback)")
        } catch {
            fatalError("Could not create any ModelContainer: \(error)")
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

        do {
            // Seed default categories if none exist
            let categoryDescriptor = FetchDescriptor<EditableListItem>(
                predicate: #Predicate { $0.type == CATEGORY }
            )
            let existingCategories = try context.fetch(categoryDescriptor)
            if existingCategories.isEmpty {
                let defaultCategories = ["Food", "Transport", "Shopping", "Entertainment", "Bills", "Other"]
                for categoryName in defaultCategories {
                    context.insert(EditableListItem(text: categoryName, type: CATEGORY))
                }
            }

            // Seed default reflections if none exist
            let mediationDescriptor = FetchDescriptor<EditableListItem>(
                predicate: #Predicate { $0.type == MEDIATION }
            )
            let existingMediations = try context.fetch(mediationDescriptor)
            if existingMediations.isEmpty {
                let defaultMediations = [
                    "Take a moment to reflect on this purchase.",
                    "Will this bring lasting value?",
                    "Is this aligned with your goals?"
                ]
                for mediationText in defaultMediations {
                    context.insert(EditableListItem(text: mediationText, type: MEDIATION))
                }
            }

            // Seed default budgets if none exist
            let necessaryBudgetDescriptor = FetchDescriptor<BudgetModel>(
                predicate: #Predicate { $0.type == NECESSARY }
            )
            if (try context.fetch(necessaryBudgetDescriptor)).isEmpty {
                context.insert(BudgetModel(type: NECESSARY, amount: 0))
            }

            let discretionaryBudgetDescriptor = FetchDescriptor<BudgetModel>(
                predicate: #Predicate { $0.type == DISCRETIONARY }
            )
            if (try context.fetch(discretionaryBudgetDescriptor)).isEmpty {
                context.insert(BudgetModel(type: DISCRETIONARY, amount: 0))
            }

            try context.save()
        } catch {
            print("Error initializing default data: \(error)")
        }
    }
}

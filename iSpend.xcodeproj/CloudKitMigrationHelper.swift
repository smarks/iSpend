//
//  CloudKitMigrationHelper.swift
//  iSpend
//
//  Created by Spencer Marks on 9/18/25.
//

import Foundation
import SwiftData
import CloudKit

/// Helper class to manage CloudKit data migration and sync operations
class CloudKitMigrationHelper: ObservableObject {
    @Published var migrationStatus: MigrationStatus = .notStarted
    @Published var syncProgress: SyncProgress?
    
    enum MigrationStatus {
        case notStarted
        case inProgress
        case completed
        case failed(Error)
        
        var description: String {
            switch self {
            case .notStarted:
                return "Ready to migrate"
            case .inProgress:
                return "Migrating data..."
            case .completed:
                return "Migration completed"
            case .failed(let error):
                return "Migration failed: \(error.localizedDescription)"
            }
        }
    }
    
    struct SyncProgress {
        let totalItems: Int
        let processedItems: Int
        
        var percentage: Double {
            guard totalItems > 0 else { return 0 }
            return Double(processedItems) / Double(totalItems) * 100
        }
    }
    
    /// Check if this is a first-time CloudKit setup for existing data
    func shouldOfferMigration(modelContext: ModelContext) -> Bool {
        // Check if there's local data but no CloudKit sync has occurred
        do {
            let expenseDescriptor = FetchDescriptor<ExpenseModel>()
            let expenses = try modelContext.fetch(expenseDescriptor)
            
            // If we have expenses but haven't synced to CloudKit yet
            return !expenses.isEmpty && !UserDefaults.standard.bool(forKey: "hasCompletedCloudKitMigration")
        } catch {
            print("Error checking for migration: \(error)")
            return false
        }
    }
    
    /// Perform initial CloudKit setup and data migration
    func performInitialCloudKitSetup(modelContext: ModelContext) async {
        await MainActor.run {
            migrationStatus = .inProgress
        }
        
        do {
            // The ModelContainer with CloudKit configuration will automatically
            // handle the migration of existing SwiftData records to CloudKit
            
            // We just need to ensure all existing records have proper UUIDs
            try await ensureUniqueIdentifiers(modelContext: modelContext)
            
            await MainActor.run {
                migrationStatus = .completed
                UserDefaults.standard.set(true, forKey: "hasCompletedCloudKitMigration")
            }
            
        } catch {
            await MainActor.run {
                migrationStatus = .failed(error)
            }
        }
    }
    
    private func ensureUniqueIdentifiers(modelContext: ModelContext) async throws {
        // Ensure all existing records have unique identifiers for CloudKit
        let expenseDescriptor = FetchDescriptor<ExpenseModel>()
        let expenses = try modelContext.fetch(expenseDescriptor)
        
        let budgetDescriptor = FetchDescriptor<BudgetModel>()
        let budgets = try modelContext.fetch(budgetDescriptor)
        
        let itemDescriptor = FetchDescriptor<EditableListItem>()
        let items = try modelContext.fetch(itemDescriptor)
        
        await MainActor.run {
            syncProgress = SyncProgress(
                totalItems: expenses.count + budgets.count + items.count,
                processedItems: 0
            )
        }
        
        var processed = 0
        
        // Process expenses
        for expense in expenses {
            // The UUID should already be set in the updated init, but just in case
            if expense.id == UUID(uuidString: "00000000-0000-0000-0000-000000000000") {
                expense.id = UUID()
            }
            processed += 1
            await MainActor.run {
                syncProgress = SyncProgress(totalItems: syncProgress?.totalItems ?? 0, processedItems: processed)
            }
        }
        
        // Process budgets
        for budget in budgets {
            if budget.id == UUID(uuidString: "00000000-0000-0000-0000-000000000000") {
                budget.id = UUID()
            }
            processed += 1
            await MainActor.run {
                syncProgress = SyncProgress(totalItems: syncProgress?.totalItems ?? 0, processedItems: processed)
            }
        }
        
        // Process list items
        for item in items {
            if item.id == UUID(uuidString: "00000000-0000-0000-0000-000000000000") {
                item.id = UUID()
            }
            processed += 1
            await MainActor.run {
                syncProgress = SyncProgress(totalItems: syncProgress?.totalItems ?? 0, processedItems: processed)
            }
        }
        
        try modelContext.save()
    }
    
    /// Check CloudKit sync status
    func checkCloudKitAvailability() async -> Bool {
        let container = CKContainer.default()
        
        do {
            let status = try await container.accountStatus()
            return status == .available
        } catch {
            print("CloudKit availability check failed: \(error)")
            return false
        }
    }
}
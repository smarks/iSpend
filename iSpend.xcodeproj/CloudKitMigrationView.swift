//
//  CloudKitMigrationView.swift
//  iSpend
//
//  Created by Spencer Marks on 9/18/25.
//

import SwiftUI
import SwiftData

struct CloudKitMigrationView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @StateObject private var migrationHelper = CloudKitMigrationHelper()
    @State private var showingMigration = false
    @State private var cloudKitAvailable = false
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Image(systemName: "icloud.and.arrow.up")
                    .font(.system(size: 60))
                    .foregroundColor(.blue)
                
                Text("Enable iCloud Sync")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                Text("Sync your spending data across all your devices automatically.")
                    .font(.body)
                    .multilineTextAlignment(.center)
                    .foregroundColor(.secondary)
                
                VStack(alignment: .leading, spacing: 12) {
                    FeatureRow(icon: "arrow.triangle.2.circlepath", text: "Automatic sync across devices")
                    FeatureRow(icon: "lock.shield", text: "Secure and private with end-to-end encryption")
                    FeatureRow(icon: "iphone.and.ipad", text: "Access your data on iPhone, iPad, and Mac")
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(12)
                
                if migrationHelper.migrationStatus == .inProgress {
                    VStack(spacing: 8) {
                        ProgressView()
                            .scaleEffect(1.2)
                        
                        Text(migrationHelper.migrationStatus.description)
                            .font(.subheadline)
                        
                        if let progress = migrationHelper.syncProgress {
                            Text("\(progress.processedItems) of \(progress.totalItems) items")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding()
                    .background(Color(.systemBackground))
                    .cornerRadius(8)
                    .shadow(radius: 2)
                }
                
                Spacer()
                
                VStack(spacing: 12) {
                    if cloudKitAvailable && migrationHelper.migrationStatus == .notStarted {
                        Button("Enable iCloud Sync") {
                            Task {
                                await migrationHelper.performInitialCloudKitSetup(modelContext: modelContext)
                            }
                        }
                        .buttonStyle(.borderedProminent)
                        .controlSize(.large)
                    } else if migrationHelper.migrationStatus == .completed {
                        Button("Done") {
                            dismiss()
                        }
                        .buttonStyle(.borderedProminent)
                        .controlSize(.large)
                    } else if !cloudKitAvailable {
                        VStack(spacing: 8) {
                            Text("iCloud is not available")
                                .font(.headline)
                                .foregroundColor(.red)
                            
                            Text("Please sign in to iCloud in Settings to enable sync.")
                                .font(.subheadline)
                                .multilineTextAlignment(.center)
                                .foregroundColor(.secondary)
                            
                            Button("Open Settings") {
                                if let settingsURL = URL(string: UIApplication.openSettingsURLString) {
                                    UIApplication.shared.open(settingsURL)
                                }
                            }
                            .buttonStyle(.bordered)
                        }
                    }
                    
                    Button("Skip for Now") {
                        UserDefaults.standard.set(true, forKey: "hasSkippedCloudKitSetup")
                        dismiss()
                    }
                    .buttonStyle(.plain)
                    .foregroundColor(.secondary)
                }
            }
            .padding()
            .navigationTitle("iCloud Sync")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
        .task {
            cloudKitAvailable = await migrationHelper.checkCloudKitAvailability()
        }
    }
}

struct FeatureRow: View {
    let icon: String
    let text: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(.blue)
                .frame(width: 24, height: 24)
            
            Text(text)
                .font(.subheadline)
            
            Spacer()
        }
    }
}

#Preview {
    CloudKitMigrationView()
}
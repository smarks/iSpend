//
//  CloudSyncStatusView.swift
//  iSpend
//
//  Created by Spencer Marks on 9/18/25.
//

import SwiftUI
import CloudKit
import SwiftData

struct CloudSyncStatusView: View {
    @State private var cloudKitStatus: CloudKitStatus = .unknown
    @State private var userRecordID: CKRecord.ID?
    @State private var showingSignInAlert = false
    
    enum CloudKitStatus {
        case available
        case notAvailable(String)
        case noAccount
        case restricted
        case unknown
        
        var description: String {
            switch self {
            case .available:
                return "iCloud sync is active"
            case .notAvailable(let reason):
                return "iCloud sync unavailable: \(reason)"
            case .noAccount:
                return "No iCloud account signed in"
            case .restricted:
                return "iCloud sync is restricted"
            case .unknown:
                return "Checking iCloud status..."
            }
        }
        
        var systemImage: String {
            switch self {
            case .available:
                return "icloud.fill"
            case .notAvailable, .noAccount, .restricted:
                return "icloud.slash"
            case .unknown:
                return "icloud"
            }
        }
        
        var color: Color {
            switch self {
            case .available:
                return .green
            case .notAvailable, .noAccount, .restricted:
                return .red
            case .unknown:
                return .gray
            }
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: cloudKitStatus.systemImage)
                    .foregroundColor(cloudKitStatus.color)
                Text("iCloud Sync")
                    .font(.headline)
                Spacer()
            }
            
            Text(cloudKitStatus.description)
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            if case .noAccount = cloudKitStatus {
                Button("Sign in to iCloud") {
                    showingSignInAlert = true
                }
                .buttonStyle(.borderedProminent)
            }
            
            if case .available = cloudKitStatus {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Your spending data syncs automatically across all your devices signed in with the same Apple ID.")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    if let userRecordID = userRecordID {
                        Text("Account: \(userRecordID.recordName)")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(10)
        .onAppear {
            checkCloudKitStatus()
        }
        .alert("Sign in to iCloud", isPresented: $showingSignInAlert) {
            Button("Settings") {
                if let settingsURL = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(settingsURL)
                }
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("To sync your spending data across devices, sign in to iCloud in Settings.")
        }
    }
    
    private func checkCloudKitStatus() {
        let container = CKContainer.default()
        
        container.accountStatus { status, error in
            DispatchQueue.main.async {
                if let error = error {
                    self.cloudKitStatus = .notAvailable(error.localizedDescription)
                    return
                }
                
                switch status {
                case .available:
                    self.cloudKitStatus = .available
                    // Get user record ID for display
                    container.fetchUserRecordID { recordID, _ in
                        DispatchQueue.main.async {
                            self.userRecordID = recordID
                        }
                    }
                case .noAccount:
                    self.cloudKitStatus = .noAccount
                case .restricted:
                    self.cloudKitStatus = .restricted
                case .couldNotDetermine:
                    self.cloudKitStatus = .notAvailable("Could not determine iCloud status")
                @unknown default:
                    self.cloudKitStatus = .unknown
                }
            }
        }
    }
}

#Preview {
    CloudSyncStatusView()
        .padding()
}
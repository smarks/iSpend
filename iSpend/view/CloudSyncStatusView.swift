import SwiftUI
import CloudKit

struct CloudSyncStatusView: View {
    @State private var iCloudAvailable: Bool = false
    @State private var statusMessage: String = "Checking iCloud…"
    @State private var lastChange: Date? = nil

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 8) {
                Image(systemName: iCloudAvailable ? "icloud" : "icloud.slash")
                    .foregroundStyle(iCloudAvailable ? .blue : .red)
                Text(iCloudAvailable ? "iCloud Available" : "iCloud Unavailable")
                    .font(.headline)
            }

            Text(statusMessage)
                .font(.subheadline)
                .foregroundStyle(.secondary)

            if let lastChange {
                HStack(spacing: 6) {
                    Image(systemName: "arrow.triangle.2.circlepath")
                        .foregroundStyle(.secondary)
                    Text("Last change: \(lastChange, style: .time)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(.thinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .onAppear {
            refreshStatus()
        }
        .onReceive(NotificationCenter.default.publisher(for: .NSPersistentStoreRemoteChange)) { _ in
            lastChange = Date()
        }
    }

    private func refreshStatus() {
        CKContainer.default().accountStatus { status, error in
            DispatchQueue.main.async {
                switch status {
                case .available:
                    self.iCloudAvailable = true
                case .noAccount, .restricted, .couldNotDetermine:
                    self.iCloudAvailable = false
                @unknown default:
                    self.iCloudAvailable = false
                }
                if let error {
                    self.statusMessage = "iCloud check error: \(error.localizedDescription)"
                } else {
                    self.statusMessage = self.iCloudAvailable ? "Sync is enabled for this device" : "Sync off (local-only mode)"
                }
            }
        }
    }
}

#Preview {
    CloudSyncStatusView()
        .padding()
}

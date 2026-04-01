import Foundation
import SwiftData
import SwiftUI
import UniformTypeIdentifiers

struct DataManagementView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.modelContext) private var modelContext

    var expenses: [ExpenseModel]

    // Export
    @State private var showShareSheet = false

    // Resets
    @State private var showExpenseResetConfirm = false
    @State private var showBudgetResetConfirm = false
    @State private var showCategoryResetConfirm = false

    // Import
    @State private var showFileImporter = false
    @State private var pendingImportExpenses: [ExpenseModel] = []
    @State private var showImportOptions = false
    @State private var importResultMessage = ""
    @State private var showImportResultAlert = false

    // Shared error
    @State private var showErrorAlert = false
    @State private var errorMessage = ""

    var body: some View {
        NavigationStack {
            List {
                Section("Danger Zone") {
                    Button("Reset all expense data", role: .destructive) {
                        showExpenseResetConfirm = true
                    }
                    Button("Reset budget data", role: .destructive) {
                        showBudgetResetConfirm = true
                    }
                    Button("Reset categories and reflections", role: .destructive) {
                        showCategoryResetConfirm = true
                    }
                }

                Section("Export") {
                    if expenses.isEmpty {
                        Text("No data to export")
                            .foregroundStyle(.secondary)
                    } else {
                        Button {
                            exportData()
                        } label: {
                            Label("Export \(expenses.count) record(s)", systemImage: "square.and.arrow.up")
                        }
                    }
                }

                Section("Import") {
                    Button {
                        importFromClipboard()
                    } label: {
                        Label("Import from Clipboard", systemImage: "doc.on.clipboard")
                    }
                    Button {
                        showFileImporter = true
                    } label: {
                        Label("Import from File", systemImage: "doc.badge.plus")
                    }
                }
            }
            .navigationTitle("Data Management")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") { dismiss() }
                }
            }
            // All modals at NavigationStack level to avoid SwiftUI single-modal-per-view limits.
            .confirmationDialog("Delete all expense data?", isPresented: $showExpenseResetConfirm, titleVisibility: .visible) {
                Button("Delete", role: .destructive) {
                    deleteModel(ExpenseModel.self, errorMessage: "Failed to clear expense data")
                }
            }
            .confirmationDialog("Delete budget data?", isPresented: $showBudgetResetConfirm, titleVisibility: .visible) {
                Button("Delete", role: .destructive) {
                    deleteModel(BudgetModel.self, errorMessage: "Failed to clear budget data")
                }
            }
            .confirmationDialog("Delete all categories and reflections?", isPresented: $showCategoryResetConfirm, titleVisibility: .visible) {
                Button("Delete", role: .destructive) {
                    deleteModel(EditableListItem.self, errorMessage: "Failed to delete categories and reflections")
                }
            }
            .sheet(isPresented: $showShareSheet) {
                ActivityShareSheet(items: [csvExportURL])
                    .ignoresSafeArea()
            }
            .fileImporter(
                isPresented: $showFileImporter,
                allowedContentTypes: [.commaSeparatedText, .plainText],
                allowsMultipleSelection: false
            ) { result in
                importFromFile(result: result)
            }
            .confirmationDialog(
                "Import \(pendingImportExpenses.count) record(s)?",
                isPresented: $showImportOptions,
                titleVisibility: .visible
            ) {
                Button("Replace all existing data") {
                    performImport(replace: true)
                }
                Button("Merge (skip duplicates)") {
                    performImport(replace: false)
                }
            } message: {
                Text("Replace deletes all current expenses first. Merge keeps existing data and skips duplicates (matched by name, date, and amount).")
            }
            .alert("Import Complete", isPresented: $showImportResultAlert) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(importResultMessage)
            }
            .alert("Error", isPresented: $showErrorAlert) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(errorMessage)
            }
        }
    }

    // MARK: - Export

    private func exportData() {
        let csv = generateCSV(from: expenses)
        // Copy to clipboard so Import from Clipboard works immediately after
        UIPasteboard.general.setValue(csv, forPasteboardType: UTType.commaSeparatedText.identifier)
        UIPasteboard.general.string = csv
        showShareSheet = true
    }

    /// Writes CSV to a dated temp file and returns its URL for the share sheet.
    private var csvExportURL: URL {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let url = FileManager.default.temporaryDirectory
            .appendingPathComponent("ispend-\(formatter.string(from: Date())).csv")
        try? generateCSV(from: expenses).write(to: url, atomically: true, encoding: .utf8)
        return url
    }

    // MARK: - Import

    private func importFromClipboard() {
        guard let text = UIPasteboard.general.string, !text.isEmpty else {
            errorMessage = "No text found on the clipboard."
            showErrorAlert = true
            return
        }
        processImportContent(text)
    }

    private func importFromFile(result: Result<[URL], Error>) {
        switch result {
        case .success(let urls):
            guard let url = urls.first else { return }
            guard url.startAccessingSecurityScopedResource() else {
                errorMessage = "Could not access the selected file."
                showErrorAlert = true
                return
            }
            defer { url.stopAccessingSecurityScopedResource() }
            guard let content = try? String(contentsOf: url, encoding: .utf8) else {
                errorMessage = "Could not read the file. Make sure it's a plain-text CSV."
                showErrorAlert = true
                return
            }
            processImportContent(content)
        case .failure(let error):
            errorMessage = "File import failed: \(error.localizedDescription)"
            showErrorAlert = true
        }
    }

    private func processImportContent(_ content: String) {
        let (parsed, failedRows) = parseCSV(content)
        guard !parsed.isEmpty else {
            errorMessage = failedRows > 0
                ? "No valid expense data found. \(failedRows) row(s) could not be parsed."
                : "No expense data found."
            showErrorAlert = true
            return
        }
        pendingImportExpenses = parsed
        showImportOptions = true
    }

    private func performImport(replace: Bool) {
        if replace {
            try? modelContext.delete(model: ExpenseModel.self)
        }

        let existingExpenses: [ExpenseModel] = replace
            ? []
            : (try? modelContext.fetch(FetchDescriptor<ExpenseModel>())) ?? []

        let calendar = Calendar.current
        var insertedCount = 0
        var skippedCount = 0

        for expense in pendingImportExpenses {
            let isDuplicate = existingExpenses.contains { existing in
                existing.name == expense.name &&
                existing.amount == expense.amount &&
                calendar.isDate(existing.date, inSameDayAs: expense.date)
            }
            if isDuplicate {
                skippedCount += 1
            } else {
                modelContext.insert(expense)
                insertedCount += 1
            }
        }

        pendingImportExpenses = []
        var message = "\(insertedCount) record(s) imported."
        if skippedCount > 0 { message += " \(skippedCount) duplicate(s) skipped." }
        importResultMessage = message
        showImportResultAlert = true
    }

    // MARK: - Shared helpers

    private func deleteModel<T: PersistentModel>(_ type: T.Type, errorMessage: String) {
        do {
            try modelContext.delete(model: type)
            dismiss()
        } catch {
            self.errorMessage = errorMessage
            showErrorAlert = true
        }
    }

    // generateCSV and parseCSV are defined in Utils.swift as free functions.
}

// MARK: - UIActivityViewController wrapper

private struct ActivityShareSheet: UIViewControllerRepresentable {
    let items: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

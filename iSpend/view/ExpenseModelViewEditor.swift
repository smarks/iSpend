//
//  ExpenseModelViewEditor.swift
//  iSpend
//
//  Created by Spencer Marks on 8/15/24.
//

import Foundation
import SwiftUI
import SwiftData

struct ExpenseModelViewEditor: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @Query(filter: #Predicate<EditableListItem> { item in item.type == CATEGORY })
    private var categories: [EditableListItem]

    @Query(filter: #Predicate<EditableListItem> { item in item.type == MEDIATION })
    private var mediations: [EditableListItem]

    @State var expenseModel: ExpenseModel
    private let isNew: Bool

    let types = [ExpenseType.necessary, ExpenseType.discretionary]

    @State private var messageToReflectOn: String = ""

    /// All known category names from the query, plus the expense's current
    /// category if it was deleted from Settings (prevents an orphaned selection).
    private var categoryNames: [String] {
        var names = categories.map(\.text)
        let current = expenseModel.category
        if current != "None" && !names.contains(current) {
            names.append(current)
        }
        return names
    }

    /// Flat list of every picker option so ForEach drives the entire menu.
    /// Avoids a SwiftUI quirk where static items after ForEach can vanish.
    private var allCategoryOptions: [(id: String, label: String)] {
        var opts: [(id: String, label: String)] = [("None", "None")]
        for name in categoryNames {
            opts.append((name, name))
        }
        opts.append(("__new__", "New Category…"))
        return opts
    }

    private var categoryPicker: some View {
        VStack(alignment: .leading, spacing: 8) {
            Picker("Category", selection: $selectedCategory) {
                ForEach(allCategoryOptions, id: \.id) { option in
                    Text(option.label).tag(option.id)
                }
            }
            .pickerStyle(MenuPickerStyle())
            .onChange(of: selectedCategory) { _, newValue in
                if newValue == "__new__" {
                    isAddingNewCategory = true
                    newCategoryText = ""
                } else {
                    isAddingNewCategory = false
                    expenseModel.category = newValue
                }
            }

            if isAddingNewCategory {
                TextField("Type new category name", text: $newCategoryText)
                    .submitLabel(.done)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .focused($isNewCategoryFocused)
                    .onSubmit { finaliseNewCategory() }
                    .onAppear { isNewCategoryFocused = true }
            }
        }
    }

    private func finaliseNewCategory() {
        let trimmed = newCategoryText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        // Re-use existing category if one matches (case-insensitive) to avoid duplicates.
        if let existing = categories.first(where: { $0.text.caseInsensitiveCompare(trimmed) == .orderedSame }) {
            expenseModel.category = existing.text
            selectedCategory = existing.text
        } else {
            let newItem = EditableListItem(text: trimmed, type: CATEGORY)
            modelContext.insert(newItem)
            // Save immediately so @Query picks it up and the Picker tag exists.
            try? modelContext.save()
            expenseModel.category = trimmed
            selectedCategory = trimmed
        }
        isAddingNewCategory = false
    }

    private var datePicker: some View {
        DatePicker("Date", selection: $expenseModel.date, in: ...Date())
    }

    init(expenseModel: ExpenseModel, isNew: Bool = false) {
        self.expenseModel = expenseModel
        self.isNew = isNew
        self._selectedCategory = State(initialValue: expenseModel.category)
        // Normalize discretionaryValue to the slider range 1...7.
        // Handles new expenses (default is 0) and old expenses saved before
        // the slider existed. Seed based on typeMap so the slider starts in
        // the right zone (necessary → 2 "Important", discretionary → 5 "Discretionary").
        if expenseModel.discretionaryValue < 1 || expenseModel.discretionaryValue > 7 {
            expenseModel.discretionaryValue = expenseModel.typeMap == DISCRETIONARY ? 5 : 2
        }
    }

    private var disableSave: Bool {
        expenseModel.name.isEmpty || expenseModel.amount <= 0
    }

    private var typeColor: Color {
        // Must stay in sync with ExpenseModelView.priorityColor
        colorForLevel(Int(expenseModel.discretionaryValue))
    }

    private func colorForLevel(_ level: Int) -> Color {
        switch level {
        case 1:     return .green
        case 2:     return Color(red: 0.6, green: 0.8, blue: 0.2)   // lime
        case 3:     return .yellow
        case 4:     return .orange
        case 5:     return Color(red: 0.95, green: 0.5, blue: 0.2)  // dark orange
        case 6:     return Color(red: 0.95, green: 0.35, blue: 0.3) // warm red
        default:    return .red
        }
    }

    private var priorityLabel: String {
        switch expenseModel.discretionaryValue {
        case 1: return "Essential"
        case 2: return "Important"
        case 3: return "Necessary"
        case 4: return "Could Skip"
        case 5: return "Discretionary"
        case 6: return "Indulgent"
        case 7: return "Don't Do It"
        default: return "–"
        }
    }

    private var reflectionSection: some View {
        Section {
            Text(messageToReflectOn)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                .italic()
        } header: {
            Text("Reflection")
        }
    }

    private var typePicker: some View {
        Picker("Type", selection: $expenseModel.expenseType) {
            ForEach(types, id: \.self) { type in
                Text(type.rawValue)
            }
        }
    }

    @State private var selectedCategory: String
    @State private var isAddingNewCategory = false
    @State private var newCategoryText = ""

    @FocusState private var isFocused: Bool
    @FocusState private var isNewCategoryFocused: Bool

    var body: some View {
        NavigationStack {
            Form {
                reflectionSection

                HStack {
                    Text("Description:")
                    TextField("Name", text: $expenseModel.name)
                        .focused($isFocused)
                        .submitLabel(.done)
                        .onChange(of: isFocused) {
                            if !isFocused && expenseModel.amount == 0.0 {
                                let result = separateNumbersAndLetters(from: expenseModel.name)
                                expenseModel.amount = result.number ?? 0.0
                                expenseModel.name = result.letters
                            }
                        }
                }

                HStack {
                    Text("Amount:")
                    TextField("Enter amount", value: $expenseModel.amount, format: .localCurrency)
                        .keyboardType(.decimalPad)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }

                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("Priority:")
                        Spacer()
                        Text(priorityLabel)
                            .fontWeight(.semibold)
                            .foregroundColor(typeColor)
                            .contentTransition(.numericText())
                            .animation(.easeInOut(duration: 0.15), value: priorityLabel)
                    }

                    HStack(spacing: 0) {
                        ForEach(1...7, id: \.self) { level in
                            Button {
                                expenseModel.discretionaryValue = Double(level)
                                expenseModel.typeMap = level > 3 ? DISCRETIONARY : NECESSARY
                                UIImpactFeedbackGenerator(style: level > 3 ? .medium : .light).impactOccurred()
                            } label: {
                                Circle()
                                    .fill(colorForLevel(level))
                                    .frame(width: 30, height: 30)
                                    .overlay {
                                        if Int(expenseModel.discretionaryValue) == level {
                                            Circle()
                                                .strokeBorder(.white, lineWidth: 3)
                                                .shadow(radius: 2)
                                        }
                                    }
                            }
                            .buttonStyle(.plain)
                            .frame(maxWidth: .infinity)
                        }
                    }

                    HStack {
                        Text("Essential")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Spacer()
                        Text("Luxury")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }

                TextField("Notes", text: $expenseModel.note)
                    .submitLabel(.done)

                datePicker

                categoryPicker
            }
            .ignoresSafeArea(.keyboard, edges: .bottom)
            .scrollDismissesKeyboard(.interactively)
            .onAppear {
                if messageToReflectOn.isEmpty {
                    messageToReflectOn = mediations.randomElement()?.text ?? "Take a moment to reflect on this purchase."
                }
            }
            .navigationTitle("Expense Editor")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        saveActivity()
                        dismiss()
                    }
                    .disabled(disableSave)
                }
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") {
                        cancelActivity()
                        dismiss()
                    }
                }
            }
        }
    }

    private func saveActivity() {
        if isAddingNewCategory { finaliseNewCategory() }
        if isNew {
            modelContext.insert(expenseModel)
        }
        do {
            try modelContext.save()
        } catch {
            print("Save failed: \(error)")
        }
    }

    private func cancelActivity() {
        if !isNew {
            // Discard any unsaved edits to the existing model.
            modelContext.rollback()
        }
        // New models were never inserted, so they're simply discarded.
    }
}

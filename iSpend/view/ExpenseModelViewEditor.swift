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

    private var messageToReflectOn: String {
        mediations.randomElement()?.text ?? "Take a moment to reflect on this purchase."
    }

    private var categoryPicker: some View {
        VStack(alignment: .leading, spacing: 8) {
            Picker("Category", selection: $selectedCategory) {
                Text("None").tag("None")
                ForEach(categories, id: \.text) { category in
                    Text(category.text).tag(category.text)
                }
                Text("New Category…").tag("__new__")
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
        let trimmed = newCategoryText.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return }
        expenseModel.category = trimmed
        if !categories.contains(where: { $0.text.lowercased() == trimmed.lowercased() }) {
            modelContext.insert(EditableListItem(text: trimmed, type: CATEGORY))
        }
        isAddingNewCategory = false
        selectedCategory = trimmed
    }

    private var datePicker: some View {
        DatePicker("Date", selection: $expenseModel.date, in: ...Date())
    }

    init(expenseModel: ExpenseModel, isNew: Bool = false) {
        self.expenseModel = expenseModel
        self.isNew = isNew
        self._selectedCategory = State(initialValue: expenseModel.category)
        if isNew {
            expenseModel.discretionaryValue = 1
        }
    }

    private var disableSave: Bool {
        expenseModel.name.isEmpty || expenseModel.amount <= 0
    }

    private var typeColor: Color {
        if expenseModel.discretionaryValue <= 3 {
            return Color.green
        } else if expenseModel.discretionaryValue <= 5 {
            return Color.orange
        } else {
            return Color.red
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
        default: return "Luxury"
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

                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text("Priority:")
                        Spacer()
                        Text(priorityLabel)
                            .fontWeight(.semibold)
                            .foregroundColor(typeColor)
                            .animation(.easeInOut(duration: 0.15), value: priorityLabel)
                    }

                    Slider(value: $expenseModel.discretionaryValue, in: 1...7, step: 1)
                        .tint(typeColor)
                        .onChange(of: expenseModel.discretionaryValue) { _, newValue in
                            expenseModel.typeMap = newValue > 3 ? DISCRETIONARY : NECESSARY
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

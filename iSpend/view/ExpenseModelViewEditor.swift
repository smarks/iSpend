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
        Picker("Category", selection: $expenseModel.category) {
            Text("None").tag("None")
            ForEach(categories, id: \.text) { category in
                Text(category.text).tag(category.text)
            }
        }
        .pickerStyle(MenuPickerStyle())
    }

    private var datePicker: some View {
        DatePicker("Date", selection: $expenseModel.date, in: ...Date())
    }

    init(expenseModel: ExpenseModel, isNew: Bool = false) {
        self.expenseModel = expenseModel
        self.isNew = isNew
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

    @FocusState private var isFocused: Bool

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
                        Text(expenseModel.expenseType.rawValue)
                            .fontWeight(.bold)
                            .foregroundColor(typeColor)
                        Spacer()
                        Text(String(format: "%.0f", expenseModel.discretionaryValue))
                            .foregroundColor(.secondary)
                    }

                    Slider(value: $expenseModel.discretionaryValue, in: 1...7, step: 1)
                        .accentColor(typeColor)
                        .onChange(of: expenseModel.discretionaryValue) { _, newValue in
                            expenseModel.typeMap = newValue > 3 ? DISCRETIONARY : NECESSARY
                        }
                }

                typePicker
                    .onChange(of: expenseModel.expenseType) {
                        if expenseModel.expenseType == .necessary {
                            expenseModel.discretionaryValue = 1
                        } else {
                            expenseModel.discretionaryValue = 7
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
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        saveActivity()
                        dismiss()
                    }.disabled(disableSave)
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

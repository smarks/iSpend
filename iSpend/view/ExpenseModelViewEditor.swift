//
//  ExpenseModelView.swift
//  iSpend
//
//  Created by Spencer Marks on 8/15/24.
//

import Foundation
import SwiftUI

var dateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateFormat = "MM-dd"
    return formatter
}()

struct ExpenseModelViewEditor: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @State var expenseModel: ExpenseModel
    @State var originalExpenseModel: ExpenseModel
    @State private var categories: [String] = Categories().list
    @State private var stringAmount: String = ""
    @State private var discretionaryValueString: String = "0"
    @State var discretionaryValueLabel: String = "Discretionary Value"
    @State var amopuntLabel: String = "Amount"

    let messageToReflectOn: String
    let gradient = Gradient(colors: [.green, .yellow, .orange, .red])
    let types = [ExpenseTypeType.Necessary, ExpenseTypeType.Discretionary]

    private var categoryPicker: some View {
        Picker("Category", selection: $expenseModel.category) {
            ForEach(categories, id: \.self) { category in
                Text(category).tag(category)
            }
        }
        .pickerStyle(MenuPickerStyle())
    }

    private var datePicker: some View {
        DatePicker("Date", selection: $expenseModel.date, in: ...Date())
    }

    init(expenseModel: ExpenseModel) {
        self.expenseModel = expenseModel
        originalExpenseModel = expenseModel
        categories = Categories().list
        stringAmount = String(expenseModel.amount)
        discretionaryValueString = String(expenseModel.discretionaryValue)
        messageToReflectOn = Mediations().list.randomElement() ?? "Who knows what this will bring"
    }

    // If expense record is incomplete or hasn't changed, disable save button.
    private var disableSave: Bool {
        return expenseModel.name.isEmpty || expenseModel.amount <= 0.0 || expenseModel.name.count == 0
    }

    private var typeColor: Color {
        if expenseModel.discretionaryValue < 3 {
            return Color.blue
        } else if expenseModel.discretionaryValue < 6 {
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
        Picker("Type", selection: $expenseModel.typeType) {
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

                    TextField("Name", text: $expenseModel.name).focused($isFocused)
                        .onChange(of: isFocused) {
                            if !isFocused {
                                print("TextField lost focus")
                                let result = separateNumbersAndLetters(from: expenseModel.name)
                                print(result)
                                stringAmount = String(result.number ?? 0.0)
                                expenseModel.amount = result.number ?? 0.0
                                expenseModel.name = result.letters
                            }
                        }
                }

                HStack {
                    Text("Amount:")
                    NumericTextField(numericText: $stringAmount, amountDouble: $expenseModel.amount, label: amopuntLabel)
                }

                HStack {
                    Text(String(expenseModel.typeType.rawValue))
                        .fontWeight(.bold).foregroundColor(typeColor)
                        .frame(minWidth: CGFloat("DISCRETIONARY".count)).onChange(of: expenseModel.discretionaryValue) { _, newValue in
                            if newValue > 3 {
                                expenseModel.type = DISCRETIONARY
                                expenseModel.typeType = ExpenseTypeType.Discretionary
                            } else {
                                expenseModel.type = NECESSARY
                                expenseModel.typeType = ExpenseTypeType.Necessary
                            }
                        }.padding(.leading)

                    ZStack {
                        LinearGradient(gradient: gradient, startPoint: .leading, endPoint: .trailing)
                            .mask(
                                Slider(value: $expenseModel.discretionaryValue, in: 1 ... 7, step: 1)
                            )
                        Slider(value: $expenseModel.discretionaryValue, in: 1 ... 7, step: 1).opacity(0.05)
                    }
                }
                typePicker.onChange(of: expenseModel.typeType) {
                    if expenseModel.typeType == ExpenseTypeType.Necessary {
                        expenseModel.type = NECESSARY
                        expenseModel.discretionaryValue = 0
                    } else {
                        expenseModel.type = DISCRETIONARY
                        expenseModel.discretionaryValue = 7
                    }
                }

                TextField("Notes", text: $expenseModel.note)
                categoryPicker

            }.onChange(of: discretionaryValueString) { _, _ in
                expenseModel.discretionaryValue = Double(discretionaryValueString) ?? 0
            }.navigationTitle("Add new expense")
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
        print("save expense")
        // modelContext.insert(expenseModel)
        print(expenseModel)
    }

    private func cancelActivity() {
        expenseModel = originalExpenseModel // Revert to the original state
        print("Activity cancelled, reverted to original state")
    }
}

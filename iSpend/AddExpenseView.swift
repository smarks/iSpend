//
//  AddExpenseView.swift
//  Revisit
//
//  Created by Spencer Marks on 5/7/24.
//

import Foundation
import SwiftUI

struct AddExpenseView: View {
    @State private var name = ""
    @State private var type = ExpenseType.necessary
    @State private var amount = 0.0
    @State private var note = ""
    @State private var categories: [String] = Categories().list
    @State private var stringAmount: String = ""
    @State private var category: String = ""
    @State private var date: Date = Date.now
    @State private var discretionaryValue: Double = 0
    @State private var discretionaryValueString: String = "0"
    
    @State var discretionaryValueLabel:String = "Discretionary Value"
    @State var amopuntLabel:String = "Amount"

    var item:ExpenseItem?
    
    var messageToReflectOn: String
    var expenses: Expenses
    let gradient = Gradient(colors: [.green, .yellow, .orange, .red])

    @Environment(\.dismiss) var dismiss

    let types = [ExpenseType.necessary, ExpenseType.discretionary]
 
    // If expense record is incomplete or hasn't changed, disable save button.
    private var disableSave: Bool {
        name.isEmpty ||
        amount <= 0.0
    }
    
    var body: some View {
        NavigationStack {
            Form {
                reflectionSection
                TextField("Name", text: $name)
                NumericTextField(numericText: $discretionaryValueString, amountDouble:$discretionaryValue, label: $discretionaryValueLabel)
                ZStack {
                    LinearGradient(gradient: gradient, startPoint: .leading, endPoint: .trailing)
                        .mask(
                            Slider(value: $discretionaryValue, in: 1 ... 7, step: 1)
                        )
                    Slider(value: $discretionaryValue, in: 1 ... 7, step: 1).opacity(0.05)
                }
                
                typePicker
                NumericTextField(numericText: $stringAmount, amountDouble: $amount, label:$amopuntLabel)
                TextField("Notes", text: $note)
                categoryPicker
                datePicker.onChange(of:discretionaryValue) { _, _ in
                    if  discretionaryValue < 2 {
                        type = ExpenseType.necessary
                    } else {
                         type = ExpenseType.discretionary
                    }
                    discretionaryValueString = String(discretionaryValue)
                } }.onChange(of: type) { _, _ in
                    if  type == ExpenseType.discretionary {
                        discretionaryValue = 7
                    } else {
                        discretionaryValue = 1
                    }
                }.onChange(of:discretionaryValueString){_, _ in
                    discretionaryValue = Double(discretionaryValueString) ??  0
                }
            .navigationTitle("Add new expense")
            .toolbar {
                Button("Save") {
                    if (item != nil) {
                        item?.name = name
                        item?.amount = amount
                        item?.type = type
                        item?.note = note
                        item?.date = date
                        item?.category = "poop"
                        item?.discretionaryValue = discretionaryValue

                    } else {
                        let item = ExpenseItem(name: name, type: type, amount: amount, note: "", date: Date.now, category: item?.category ?? Categories.defaultValue, discretionaryValue: discretionaryValue)
                        expenses.allItems.append(item)
                    }
                        dismiss()
                }.disabled(disableSave)
            }
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
    
    private var detailsSection: some View {
        Section {
            TextField("Name", text: $name)
            typePicker
            NumericTextField( numericText: $stringAmount, amountDouble: $amount,label:$amopuntLabel)
            TextField("Notes", text: $note)
            categoryPicker
            datePicker
        } header: {
            Text("Details")
        }
    }

    private var typePicker: some View {
        Picker("Type", selection: $type) {
            ForEach(types, id: \.self) { type in
                Text(type.rawValue)
            }
        }
    }

    private var categoryPicker: some View {
        Picker("Category", selection: $category) {
            ForEach(categories, id: \.self) { category in
                Text(category).tag(category)
            }
        }
        .pickerStyle(MenuPickerStyle())
    }

    private var datePicker: some View {
        DatePicker("Date", selection: $date, in: ...Date())
    }
}

struct NumericTextField: View {
    @Binding var numericText: String
    @Binding var amountDouble: Double
    @Binding var label:String
    
    var body: some View {
        TextField(label, text: $numericText)
            .keyboardType(.decimalPad)
            .onChange(of: numericText, initial: false) { newValue, _ in
                // Filter out non-numeric characters
                let filteredText = filterNumericText(from: newValue)

                // Update the numericText with filtered value
                numericText = filteredText

                // Safely convert filtered text to Double and update amountDouble
                if let validDouble = Double(filteredText) {
                    amountDouble = validDouble
                } else {
                    // Handle invalid input gracefully, e.g., reset to 0 or keep the old value
                    amountDouble = 0.0
                }
            }
            .onReceive(NotificationCenter.default.publisher(for: UITextField.textDidBeginEditingNotification)) { obj in
                if let textField = obj.object as? UITextField {
                    textField.selectedTextRange = textField.textRange(from: textField.beginningOfDocument, to: textField.endOfDocument)
                    textField.selectAll(nil)
                }
            }
    }

    private func filterNumericText(from text: String) -> String {
        let allowedCharacterSet = CharacterSet(charactersIn: "0123456789.")
        let tokens = text.components(separatedBy: ".")

        // Allow only one '.' decimal character
        if tokens.count > 2 {
            return String(text.dropLast())
        }

        // Allow only two digits after '.' decimal character
        if tokens.count > 1 && tokens[1].count > 2 {
            return String(text.dropLast())
        }

        // Only allow digits and decimals
        return String(text.unicodeScalars.filter { allowedCharacterSet.contains($0) })
    }
}
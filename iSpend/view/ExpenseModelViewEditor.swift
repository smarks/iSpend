//
//  ExpenseModelView.swift
//  iSpend
//
//  Created by Spencer Marks on 8/15/24.
//

import Foundation
import SwiftUI
import SwiftData

var dateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateFormat = "MM-dd"
    return formatter
}()

let numberFormatter: NumberFormatter = {
       let formatter = NumberFormatter()
       formatter.numberStyle = .currency
       formatter.maximumFractionDigits = 2
       return formatter
   }()

    

struct ExpenseModelViewEditor: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @Query(CatergoriesModel)
    private var catergoriesModel: CatergoriesModel
    
    @State var expenseModel: ExpenseModel
    @State var originalExpenseModel: ExpenseModel
    @State private var categories: [EditableListItem] = CatergoriesModel().items
   // @State private var stringAmount: String = ""
    @State private var discretionaryValueString: String = "0"

    let messageToReflectOn: String
    let gradient = Gradient(colors: [.green, .yellow, .orange, .red])
    let types = [ExpenseTypeType.Necessary, ExpenseTypeType.Discretionary]

    private var categoryPicker: some View {
        Picker("Category", selection: $expenseModel.category) {
            ForEach(categories, id: \.self) { category in
                Text(category.text).tag(category)
            }
        }
        .pickerStyle(MenuPickerStyle())
    }

    private var datePicker: some View {
        DatePicker("Date", selection: $expenseModel.date, in: ...Date())
    }

    init(expenseModel: ExpenseModel) {
        print("expenseModel \(expenseModel.name)")
        self.expenseModel = expenseModel
        self.originalExpenseModel = expenseModel
        self.categories = Categories().list
        self.discretionaryValueString = String(expenseModel.discretionaryValue)
        self.messageToReflectOn = Mediations().list.randomElement() ?? "Who knows what this will bring"
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

                    TextField("Name", text: $expenseModel.name).focused($isFocused)
                        .onChange(of: isFocused) {
                            if !isFocused && expenseModel.amount == 0.0 {
                                print("TextField lost focus")
                                let result = separateNumbersAndLetters(from: expenseModel.name)
                                expenseModel.amount = result.number ?? 0.0
                                expenseModel.name = result.letters
                            }
                        }
                }

                HStack {
                    Text("Amount:")
                    TextField("Enter number", value: $expenseModel.amount, formatter:numberFormatter )
                               .keyboardType(.numberPad)
                               .textFieldStyle(RoundedBorderTextFieldStyle())
                               .padding()
                    }

                HStack {
                    Text(String(expenseModel.expenseType.rawValue))
                        .fontWeight(.bold).foregroundColor(typeColor)
                        .frame(minWidth: CGFloat("DISCRETIONARY".count)).onChange(of: expenseModel.discretionaryValue) { _, newValue in
                            if newValue > 3 {
                                expenseModel.typeMap = DISCRETIONARY
                                expenseModel.expenseType = ExpenseType.Discretionary
                            } else {
                                expenseModel.typeMap = NECESSARY
                                expenseModel.expenseType = ExpenseType.Necessary
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
                
                typePicker.onChange(of: expenseModel.expenseType) {
                
                    if expenseModel.expenseType == ExpenseType.Necessary {
                        expenseModel.typeMap = NECESSARY
                        expenseModel.discretionaryValue = 0
                    } else {
                        expenseModel.typeMap = DISCRETIONARY
                        expenseModel.discretionaryValue = 7
                    }
                }

                TextField("Notes", text: $expenseModel.note)
                categoryPicker

            }.onChange(of: discretionaryValueString) { _, _ in
                expenseModel.discretionaryValue = Double(discretionaryValueString) ?? 0
                
            }.navigationTitle("Expense Editor")
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
        modelContext.insert(expenseModel)
        print(expenseModel)
    }

    private func cancelActivity() {
        expenseModel = originalExpenseModel // Revert to the original state
        print("Activity cancelled, reverted to original state")
    }
    

     func filterNumericText(from text: String) -> String {
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

/*
 extension Array: RawRepresentable where Element: Codable {
 public init?(rawValue: String) {
 guard let data = rawValue.data(using: .utf8),
 let result = try? JSONDecoder().decode([Element].self, from: data)
 else {
 return nil
 }
 self = result
 }
 
 public var rawValue: String {
 guard let data = try? JSONEncoder().encode(self),
 let result = String(data: data, encoding: .utf8)
 else {
 return "[]"
 }
 return result
 }
 }
 */

//
//  DecimalOnlyTextField.swift
//  iSpent
//
//  Original code created by ChatGPT on 07/25/2023
//  Extended by Spencer Marks starting on 07/25/2023
//
import SwiftUI

struct NumericTextField: View {
    @Binding var numericText: String
    @Binding var amountDouble: Double
    
    var body: some View {
        TextField("Amount", text: $numericText)
            .keyboardType(.decimalPad)
            .onChange(of: numericText) { newValue in
                numericText = filterNumericText(from: newValue)
                amountDouble = Double(numericText) ??  0.0
            }
    }

    private func filterNumericText(from text: String) -> String {
        let allowedCharacterSet = CharacterSet(charactersIn: "0123456789.")

        let tokens = text.components(separatedBy: ".")

        // allow only one '.' decimal character
        if tokens.count > 2   {
            return String(text.dropLast(1))
        }
        
        // allow only two digits after ater '.' decimal character
        if (tokens.count > 1 && tokens[1].count > 2) {
            return String(text.dropLast(1))
        }

        // only allow digits and decimals
        return String(text.unicodeScalars.filter { allowedCharacterSet.contains($0) })
    }
}

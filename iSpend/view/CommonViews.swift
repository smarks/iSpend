//
//  CommonViews.swift
//  iSpend
//
//  Created by Spencer Marks on 8/19/24.
//

import Foundation
import SwiftUI

struct NumericTextField: View {
    @Binding var numericText: String
    @Binding var amountDouble: Double
    var label: String

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
            } /*
             .onReceive(NotificationCenter.default.publisher(for: UITextField.textDidBeginEditingNotification)) { obj in
                 if let textField = obj.object as? UITextField {
                     textField.selectedTextRange = textField.textRange(from: textField.beginningOfDocument, to: textField.endOfDocument)
                     textField.selectAll(nil)
                 }
             }
             */
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

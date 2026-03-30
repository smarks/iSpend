//
//  Utils.swift
//  iSpend
//
//  Created by Spencer Marks on 8/19/24.
//

import Foundation

/// Parses a string and returns the non-numeric text and the first number found.
/// For example, "Lunch 12.50" returns ("Lunch", 12.50).
func separateNumbersAndLetters(from input: String) -> (letters: String, number: Double?) {
    let numberPattern = "[0-9]+(?:\\.[0-9]+)?"
    let regex = try? NSRegularExpression(pattern: numberPattern, options: [])
    let matches = regex?.matches(in: input, options: [], range: NSRange(location: 0, length: input.utf16.count))

    var numberString: String?
    if let match = matches?.first, let range = Range(match.range, in: input) {
        numberString = String(input[range])
    }

    let number = numberString.flatMap { Double($0) }
    let letters = input.replacingOccurrences(of: numberString ?? "", with: "")
        .trimmingCharacters(in: .whitespacesAndNewlines)

    return (letters, number)
}

/// Converts an array of expenses to a CSV string with all fields.
func generateCSV(from expenses: [ExpenseModel]) -> String {
    var csv = "date,name,expenseType,amount,note,category,discretionaryValue\n"

    let dateFormatter = DateFormatter()
    dateFormatter.dateStyle = .short
    dateFormatter.timeStyle = .none

    for expense in expenses {
        let date = dateFormatter.string(from: expense.date)
        let name = expense.name.replacingOccurrences(of: "\"", with: "\"\"")
        let note = expense.note.replacingOccurrences(of: "\"", with: "\"\"")
        let category = expense.category.replacingOccurrences(of: "\"", with: "\"\"")
        csv.append("\"\(date)\",\"\(name)\",\(expense.expenseType.rawValue),\(expense.amount),\"\(note)\",\"\(category)\",\(expense.discretionaryValue)\n")
    }

    return csv
}

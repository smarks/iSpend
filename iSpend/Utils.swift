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

/// Parses a CSV string (as exported by generateCSV) into an array of ExpenseModel instances.
/// Returns the parsed models and a count of rows that could not be parsed.
func parseCSV(_ csvString: String) -> (expenses: [ExpenseModel], failedRows: Int) {
    var expenses: [ExpenseModel] = []
    var failedRows = 0

    let dateFormatter = DateFormatter()
    dateFormatter.dateStyle = .short
    dateFormatter.timeStyle = .none

    // Normalise line endings and drop blank lines
    let lines = csvString
        .replacingOccurrences(of: "\r\n", with: "\n")
        .replacingOccurrences(of: "\r", with: "\n")
        .components(separatedBy: "\n")
        .filter { !$0.isEmpty }

    // Need at least a header + one data row
    guard lines.count > 1 else { return ([], 0) }

    for line in lines.dropFirst() {
        let fields = parseCSVRow(line)
        guard fields.count >= 7 else { failedRows += 1; continue }

        guard let date = dateFormatter.date(from: fields[0]),
              let amount = Double(fields[3]),
              let discretionaryValue = Double(fields[6]) else {
            failedRows += 1
            continue
        }

        let expenseType = ExpenseType(rawValue: fields[2]) ?? .necessary
        let expense = ExpenseModel(
            name: fields[1],
            type: expenseType.intValue,
            amount: amount,
            note: fields[4],
            date: date,
            category: fields[5].isEmpty ? "None" : fields[5],
            discretionaryValue: discretionaryValue
        )
        expenses.append(expense)
    }

    return (expenses, failedRows)
}

/// Parses a single CSV row, handling quoted fields and escaped quotes (RFC 4180).
private func parseCSVRow(_ row: String) -> [String] {
    var fields: [String] = []
    var currentField = ""
    var inQuotes = false
    var index = row.startIndex

    while index < row.endIndex {
        let char = row[index]

        if inQuotes {
            if char == "\"" {
                let nextIndex = row.index(after: index)
                if nextIndex < row.endIndex && row[nextIndex] == "\"" {
                    // Escaped double-quote inside a quoted field
                    currentField.append("\"")
                    index = row.index(after: nextIndex)
                    continue
                } else {
                    inQuotes = false
                }
            } else {
                currentField.append(char)
            }
        } else {
            if char == "\"" {
                inQuotes = true
            } else if char == "," {
                fields.append(currentField)
                currentField = ""
            } else {
                currentField.append(char)
            }
        }

        index = row.index(after: index)
    }

    fields.append(currentField)
    return fields
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

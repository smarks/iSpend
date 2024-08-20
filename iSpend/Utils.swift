//
//  Utils.swift
//  iSpend
//
//  Created by Spencer Marks on 8/19/24.
//

import Foundation

/**
 * for a given string, parse it and return numbers as a double and the non numeric charactersas a string. 
 */
func separateNumbersAndLetters(from input: String) -> (letters: String, number: Double?) {
    // Define the regular expression pattern to match numbers
    let numberPattern = "[0-9]+(?:\\.[0-9]+)?"

    // Create a regular expression object
    let regex = try? NSRegularExpression(pattern: numberPattern, options: [])

    // Find matches in the input string
    let matches = regex?.matches(in: input, options: [], range: NSRange(location: 0, length: input.utf16.count))

    // Extract the number from the matches
    var numberString: String?
    if let match = matches?.first {
        if let range = Range(match.range, in: input) {
            numberString = String(input[range])
        }
    }

    // Convert the number string to a Double
    let number = numberString.flatMap { Double($0) }

    // Remove the number from the input string to get the letters
    let letters = input.replacingOccurrences(of: numberString ?? "", with: "").trimmingCharacters(in: .whitespacesAndNewlines)

    return (letters, number)
}

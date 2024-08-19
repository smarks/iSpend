//
//  Categories.swift
//  Revisit
//
//  Created by Spencer Marks on 5/7/24.
//

import Combine
import Foundation
import SwiftUI
 

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

protocol Labels: ObservableObject {
    var list: [String] { get }
}

class Categories: Labels {
    static let defaultValue: String = "None"

    @AppStorage("Categories") var list: [String] = [
        defaultValue, "Restaurant", "Misc", "HouseHold", "Hobby"]
}


class Mediations: Labels {
    @AppStorage("Mediations") var list: [String] = [
        "don't", "What would you do without it?",
        "What would you do without it?",
        "Sometimes its' OK to reward yourself.",
        "Learn from the past, and plan for the future, while living in the present."]
}
 

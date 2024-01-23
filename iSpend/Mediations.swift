//
//  Mediations.swift
//  iSpend
//
//  Created by Spencer Marks on 1/22/24.
//

import Foundation

class Mediations: ObservableObject {
    
    let defaultMediations: [String] = ["What would you do without it?", "Don't do it!", "What could you do with this money next, week, month, year?", "Sometimes its' OK to reward yourself.","Learn from the past, and plan for the future, while living in the present."]

    @Published var items = [String]() {
        didSet {
            if let encoded = try? JSONEncoder().encode(items) {
                UserDefaults.standard.set(encoded, forKey: "Mediations")
            }
        }
    }

    var mediations: [String] {
        items
    }

    init() {
        if let savedItems = UserDefaults.standard.data(forKey: "Mediations") {
            if let decodedItems = try? JSONDecoder().decode([String].self, from: savedItems) {
                items = decodedItems
                return
            }
        }

        items = defaultMediations
    }
}

//
//  Mediations.swift
//  iSpend
//
//  Created by Spencer Marks on 3/13/24.
//

import Foundation
import SwiftUI

struct Mediation: NamedItem {
    var id: UUID = UUID()
    var name: String

    init(name: String) {
        self.name = name
    }
}

// Default mediations
let what = Mediation(name: "What would you do without it?")
let dont = Mediation(name: "Don't do it!")
let future = Mediation(name: "What could you do with this money next, week, month, year?")
let sometimes_ok = Mediation(name: "Sometimes its' OK to reward yourself.")
let kungfo_panda = Mediation(name: "Learn from the past, and plan for the future, while living in the present.")

// Initialize your ItemsManager with a specific key for UserDefaults
let mediationManager = ItemsManager<Mediation>(itemsKey: "Mediations")

class Mediations: ObservableObject {
    @Published var items: [Mediation] = mediationManager.items

    init() {
        loadDefaultCategoriesIfNeeded()
    }

    func loadDefaultCategoriesIfNeeded() {
        // Load categories from UserDefaults via categoriesManager
        // If empty, use default categories
        if mediationManager.items.isEmpty {
            mediationManager.items.append(contentsOf: [what, dont, future, sometimes_ok,kungfo_panda])
            mediationManager.saveItems() // Save the default categories to UserDefaults
        }
        // Assign loaded categories to the published items property
        items = mediationManager.items
    }
}

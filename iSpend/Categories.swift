import Foundation
import SwiftUI
 
struct Category: NamedItem {
    var id: UUID = UUID()
    var name: String
    
    init(name:String) {
        self.name = name
     }
}

// Default categories
let defaultCategory = Category(name: "None")
let restaurantCategory = Category(name: "Restaurant")
let hobbyCategory = Category(name: "Hobby")
let houseHoldCategory = Category(name: "HouseHold")

// Initialize your ItemsManager with a specific key for UserDefaults
let categoriesManager = ItemsManager<Category>(itemsKey: "Categories")

class Categories: ObservableObject {
    @Published var items: [Category] = categoriesManager.items
    
    let defaultValue = defaultCategory
    init() {
        loadDefaultCategoriesIfNeeded()
    }

    func loadDefaultCategoriesIfNeeded() {
        // Load categories from UserDefaults via categoriesManager
        // If empty, use default categories
        if categoriesManager.items.isEmpty {
            categoriesManager.items.append(contentsOf: [defaultCategory, restaurantCategory, hobbyCategory, houseHoldCategory])
            categoriesManager.saveItems() // Save the default categories to UserDefaults
        }
        // Assign loaded categories to the published items property
        items = categoriesManager.items
    }
}
